<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
  request.setCharacterEncoding("UTF-8");
  String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>내 주변 풋살장</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <!-- Bootstrap (선택) -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

  <style>
    :root { --panel-w: 380px; }
    html, body { height:100%; }
    body {
      margin:0;
      background:#f8f9fa;
      height:100%;
      display:flex;
      flex-direction:column;
    }
    .page-wrap {
      flex:1;
      display:flex;
      gap:0;
      min-height:0;
    }
    #map {
      flex:1;
      min-width:0;
      height:calc(100vh - 64px);
    }
    #review-panel {
      width:var(--panel-w);
      max-width:100%;
      background:#fff;
      border-left:1px solid #e5e5e5;
      display:none;                 /* 마커 선택 전 숨김 */
      flex-shrink:0;
      height:calc(100vh - 64px);
      overflow-y:auto;
    }
    .panel-inner { padding:20px; }
    .review-item { border-bottom:1px solid #f1f3f5; padding:8px 0; }
    .badge-me { font-size:.8rem; }
    .floating {
      position:absolute; z-index:10; left:16px; top:88px;
      display:flex; gap:8px; flex-wrap:wrap;
    }
    .floating > * { box-shadow:0 2px 10px rgba(0,0,0,.08); }
    .kakao-map-wrap { position:relative; flex:1; }
  </style>
</head>
<body>

  <!-- 상단 네비게이션(프로젝트 공용 헤더가 있으면 include로 대체 가능) -->
  <nav class="navbar navbar-dark bg-dark" style="height:64px">
    <div class="container">
      <a class="navbar-brand fw-bold" href="<%=ctx%>/index.jsp">플랩풋볼</a>
      <div class="text-white-50 small">내 주변 풋살장</div>
    </div>
  </nav>

  <div class="page-wrap">
    <!-- 지도 -->
    <div class="kakao-map-wrap">
      <!-- 지도 위에 떠 있는 컨트롤 -->
      <div class="floating">
        <div class="card p-2">
          <form id="searchForm" class="d-flex gap-2">
            <input id="keyword" class="form-control" placeholder="검색어 (기본: 풋살장)" />
            <select id="radius" class="form-select">
              <option value="1500">1.5km</option>
              <option value="3000" selected>3km</option>
              <option value="5000">5km</option>
            </select>
            <button class="btn btn-primary" type="submit">검색</button>
            <button id="btnMyLoc" class="btn btn-outline-dark" type="button">내 위치</button>
          </form>
        </div>
      </div>
      <div id="map"></div>
    </div>

    <!-- 우측 리뷰 패널 -->
    <aside id="review-panel">
      <div class="panel-inner">
        <div class="d-flex justify-content-between align-items-center">
          <h5 id="place-name" class="mb-0"></h5>
          <button id="close-panel" class="btn btn-sm btn-outline-secondary">닫기</button>
        </div>

        <div id="place-meta" class="text-muted small mt-2"></div>
        <hr>

        <div id="existing-reviews" class="mb-3"></div>

        <form id="review-form">
          <div class="mb-2">
            <textarea id="review-text" class="form-control" rows="3" placeholder="리뷰를 작성하세요..."></textarea>
          </div>
          <button type="submit" class="btn btn-primary w-100">리뷰 작성</button>
        </form>
      </div>
    </aside>
  </div>

  <!-- ✅ Kakao Maps JS SDK: YOUR_APP_KEY 자리 교체! -->
  <!-- 장소검색을 쓰려면 libraries=services 필수 -->
  <script src="//dapi.kakao.com/v2/maps/sdk.js?appkey=f802c143efc8e04c44d5cbc892fe3198&libraries=services"></script>

  <script>
    // ===== 전역 참조 =====
    let map, places, geocoder;
    let userCenter = { lat: 37.626, lng: 127.062 }; // 초기 기본 위치(임의)
    let markers = [];
    let currentPlace = null;

    const panel     = document.getElementById('review-panel');
    const placeName = document.getElementById('place-name');
    const placeMeta = document.getElementById('place-meta');
    const listEl    = document.getElementById('existing-reviews');
    const formEl    = document.getElementById('review-form');
    const txtEl     = document.getElementById('review-text');
    const btnClose  = document.getElementById('close-panel');
    const btnMyLoc  = document.getElementById('btnMyLoc');
    const searchForm= document.getElementById('searchForm');
    const keywordEl = document.getElementById('keyword');
    const radiusEl  = document.getElementById('radius');

    // 임시 저장(메모리). 실제로는 AJAX로 서버 저장/조회 권장.
    const reviewStore = {}; // { [place_name]: [ "내용", ... ] }

    // ===== 유틸 =====
    function clearMarkers(){
      markers.forEach(m => m.setMap(null));
      markers = [];
    }
    function openPanel(){
      panel.style.display = 'block';
    }
    function closePanel(){
      panel.style.display = 'none';
      currentPlace = null;
    }
    function renderReviews(name){
      listEl.innerHTML = '';
      const arr = reviewStore[name] || [];
      if (arr.length === 0) {
        listEl.innerHTML = '<div class="text-muted small">아직 리뷰가 없습니다.</div>';
        return;
      }
      arr.forEach(t => {
        const div = document.createElement('div');
        div.className = 'review-item';
        div.textContent = t;
        listEl.appendChild(div);
      });
    }

    // ===== 지도 초기화 =====
    kakao.maps.load(function(){
      map = new kakao.maps.Map(document.getElementById('map'), {
        center: new kakao.maps.LatLng(userCenter.lat, userCenter.lng),
        level: 5
      });
      places   = new kakao.maps.services.Places();
      geocoder = new kakao.maps.services.Geocoder();

      // 최초엔 현재 위치로 이동 시도
      goMyLocation(() => doSearch());

      // 이벤트 바인딩
      btnMyLoc.addEventListener('click', () => goMyLocation(doSearch));
      btnClose.addEventListener('click', closePanel);

      searchForm.addEventListener('submit', (e) => {
        e.preventDefault();
        doSearch();
      });
      formEl.addEventListener('submit', (e) => {
        e.preventDefault();
        if (!currentPlace) return;
        const val = (txtEl.value || '').trim();
        if (!val) return;
        const key = currentPlace.place_name;
        if (!reviewStore[key]) reviewStore[key] = [];
        reviewStore[key].push(val);
        txtEl.value = '';
        renderReviews(key);
      });
    });

    // ===== 검색 실행 =====
    function doSearch(){
      const kw = (keywordEl.value || '풋살장').trim();
      const radius = parseInt(radiusEl.value, 10) || 3000;

      if (!kw) return;

      clearMarkers();

      // 현재 지도 중심을 기준으로 반경 검색
      const center = map.getCenter();
      const x = center.getLng();
      const y = center.getLat();

      places.keywordSearch(kw, (data, status) => {
        if (status !== kakao.maps.services.Status.OK) {
          alert('검색 결과가 없습니다.');
          return;
        }
        // 마커 생성
        data.forEach(place => addPlaceMarker(place));

        // 첫 결과로 패널 오픈(선택)
        if (data.length > 0) {
          selectPlace(data[0]);
        }
      }, { x, y, radius });
    }

    // ===== 마커/선택 처리 =====
    function addPlaceMarker(place){
      const marker = new kakao.maps.Marker({
        position: new kakao.maps.LatLng(place.y, place.x),
        map
      });
      kakao.maps.event.addListener(marker, 'click', () => selectPlace(place));
      markers.push(marker);
    }

    function selectPlace(place){
      currentPlace = place;

      // 패널 메타
      placeName.textContent = place.place_name || '(이름 없음)';
      placeMeta.innerHTML = `
        <div>${place.road_address_name || place.address_name || ''}</div>
        <div class="text-muted small">(${Number(place.y).toFixed(5)}, ${Number(place.x).toFixed(5)})</div>
        ${place.phone ? `<div class="text-muted small">☎ ${place.phone}</div>` : ''}
      `;
      renderReviews(place.place_name);
      openPanel();

      // 지도 중심 이동 + 확대 약간
      const pos = new kakao.maps.LatLng(place.y, place.x);
      map.setCenter(pos);
      const lvl = map.getLevel();
      if (lvl > 4) map.setLevel(4);
    }

    // ===== 내 위치로 이동 =====
    function goMyLocation(callback){
      if (!navigator.geolocation) {
        if (callback) callback();
        return;
      }
      navigator.geolocation.getCurrentPosition(
        (pos) => {
          userCenter = { lat: pos.coords.latitude, lng: pos.coords.longitude };
          map.setCenter(new kakao.maps.LatLng(userCenter.lat, userCenter.lng));
          if (callback) callback();
        },
        () => { if (callback) callback(); },   // 실패해도 계속
        { enableHighAccuracy:false, timeout:5000 }
      );
    }
  </script>
</body>
</html>
