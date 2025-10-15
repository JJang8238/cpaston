<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="dto.User" %>
<%
    // 로그인 세션 확인 (둘 중 하나만 있어도 로그인으로 간주)
    User __u = (User) session.getAttribute("loginUser");
    Object __id = session.getAttribute("userId");
    Object __nm = session.getAttribute("username");
    if (__u == null && __id == null && __nm == null) {
        response.sendRedirect("index.jsp");
        return;
    }
%>

<%@ page import="java.time.LocalTime, java.util.List" %>
<%@ page import="dao.MatchDAO, dto.Match" %>
<%@ include file="include/header.jsp" %>

<%
    MatchDAO matchDAO = new MatchDAO();
    List<Match> matchList = matchDAO.getTodayMatches();
    LocalTime now = LocalTime.now();
%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8" />
<title>스포츠 예약 및 주변 풋살장</title>
<meta name="viewport" content="width=device-width, initial-scale=1" />
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />

<style>
  body{background:#f8f9fa}
  #map{width:100%;height:440px;border:1px solid #e5e5e5;border-radius:12px}
  .place-item{cursor:pointer;padding:10px 12px;border-bottom:1px solid #eee}
  .place-item:hover{background:#f9f9f9}
  .error-box{color:#c0392b;background:#fdecea;border:1px solid #f5c6cb;padding:10px;border-radius:6px;margin-top:10px}
  .section-title{font-weight:700;letter-spacing:.2px}
  .match-badge{min-width:72px;text-align:center}

  /* 리뷰 패널 */
  #reviewPanel{
    position:fixed; top:0; right:0; height:100vh; width:380px; max-width:90vw;
    background:#fff; border-left:1px solid #e5e5e5; box-shadow:-8px 0 24px rgba(0,0,0,.06);
    padding:16px 16px 90px; overflow:auto; display:none; z-index:1000;
  }
  #reviewPanel .review-item{border-bottom:1px solid #eee; padding:10px 0;}
  #reviewPanel .close-btn{position:absolute; right:12px; top:12px;}
</style>
</head>
<body>
<div class="container py-4">

  <!-- 지도 -->
  <h2 class="section-title mb-3">내 주변 풋살장</h2>
  <div id="map"></div>
  <div id="placesError" class="error-box" style="display:none;"></div>
  <ul id="placeList" class="list-group list-group-flush mt-3"></ul>

  <!-- 오늘 경기 -->
  <div class="d-flex align-items-center justify-content-between mt-5">
    <h2 class="section-title mb-0">
      오늘의 경기 예약 현황
      <small id="selectedVenueLabel" class="text-secondary" style="font-weight:500;"></small>
    </h2>
    <button id="btnResetFilter" class="btn btn-sm btn-outline-secondary" type="button" style="display:none;">전체 보기</button>
  </div>
  <div id="matchListBox" class="list-group mt-3 mb-5"></div>
</div>

<!-- 오른쪽 리뷰 패널 -->
<aside id="reviewPanel">
  <button class="btn btn-sm btn-outline-secondary close-btn" onclick="hideReviewPanel()">닫기</button>
  <h5 id="rvPlaceTitle" class="mb-2"></h5>
  <div id="rvCount" class="text-secondary mb-2"></div>
  <div id="rvList"></div>
  <div id="rvError" class="error-box" style="display:none;"></div>
</aside>

<script>
// ---------- 유틸 ----------
function stripTags(s){ return (s||"").replace(/<\/?[^>]+(>|$)/g,""); }
function norm(s){ return stripTags(String(s||"")).toLowerCase().replace(/\s+/g,'').replace(/[^\p{L}\p{N}]/gu,''); }

// ---------- 서버 데이터 직렬화 ----------
const ALL_MATCHES = [
<%
  boolean first=true;
  for (Match m: matchList){
      String timeStr = (m.getMatchTime()==null) ? "" : m.getMatchTime().toString(); // HH:MM:SS
      String hm = timeStr.isEmpty()? "" : timeStr.substring(0,5); // HH:MM
      String loc = (m.getLocation()==null) ? "" : m.getLocation();
      int cur = m.getCurrentPlayers();
      int max = m.getMaxPlayers();
      boolean cancel = cur < 12; // 네 기준 유지
      if(!first) out.print(",\n");
      first=false;
%>
  { id:<%=m.getId()%>, time:"<%=hm%>", location:"<%=loc%>", current:<%=cur%>, max:<%=max%>, cancel:<%=cancel%> }
<% } %>
];

function nowHM(){
  var d=new Date();
  var hh=String(d.getHours()).padStart(2,'0');
  var mm=String(d.getMinutes()).padStart(2,'0');
  return hh + ":" + mm;
}

// ---------- 일정 렌더링 ----------
var matchBox = document.getElementById('matchListBox');
var labelEl  = document.getElementById('selectedVenueLabel');
var resetBtn = document.getElementById('btnResetFilter');

function renderMatches(src, venueName){
  matchBox.innerHTML = "";
  var NOW = nowHM();
  var future = src.filter(function(m){ return m.time && m.time >= NOW; });

  if(venueName){
    labelEl.textContent = "– " + venueName + " 일정만 보기";
    resetBtn.style.display = "inline-block";
  }else{
    labelEl.textContent = "";
    resetBtn.style.display = "none";
  }

  if(future.length===0){
    matchBox.innerHTML = '<div class="list-group-item text-muted">현재 예약 가능한 경기가 없습니다.</div>';
    return;
  }

  future.sort(function(a,b){ return a.time.localeCompare(b.time); });

  future.forEach(function(m){
    // 상태 뱃지
    var badgeClass = m.cancel? "bg-danger":"bg-success";
    var badgeText  = m.cancel? "경기 취소":"예약중";

    // 예약 가능 판단
    var canBook = (m.time && m.time >= NOW && m.current < m.max);

    // 예약 버튼
    var btnHtml = canBook
      ? '<button id="btn-'+m.id+'" class="btn btn-sm btn-primary" onclick="bookMatch(' + m.id + ')">예약하기</button>'
      : '<button class="btn btn-sm btn-secondary" disabled>예약 불가</button>';

    var html =
      '<div>' +
        '<h5 class="mb-1">' + m.time + ' 경기</h5>' +
        '<small>' + m.location + ' | 인원: <span id="cur-'+m.id+'">' + m.current + '</span> / ' + m.max + '</small>' +
      '</div>' +
      '<div class="d-flex align-items-center gap-2">' +
        '<span class="badge ' + badgeClass + ' rounded-pill match-badge">' + badgeText + '</span>' +
        btnHtml +
      '</div>';

    var item = document.createElement('div');
    item.className = "list-group-item d-flex justify-content-between align-items-center";
    item.innerHTML = html;
    matchBox.appendChild(item);
  });
}

function filterByVenue(name){
  var key = norm(name);
  var filtered = ALL_MATCHES.filter(function(m){
    return norm(m.location).includes(key) || key.includes(norm(m.location));
  });
  renderMatches(filtered, stripTags(name));
}
resetBtn.addEventListener('click', function(){ renderMatches(ALL_MATCHES, null); });
renderMatches(ALL_MATCHES, null);

// ---------- 예약 ----------
async function bookMatch(matchId){
  if(!confirm('이 경기를 예약할까요?')) return;
  try{
    const res = await fetch('reserve', {
      method:'POST',
      headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'},
      body: new URLSearchParams({ action:'book', matchId:String(matchId) })
    });
    const out = await res.json();
    if(!out.ok){
      alert(out.msg==='full' ? '정원이 가득 찼습니다.'
           : out.msg==='already' ? '이미 예약한 경기입니다.'
           : '예약 실패: ' + out.msg);
      return;
    }
    // 인원 반영
    var curEl = document.getElementById('cur-'+matchId);
    if(curEl) curEl.textContent = out.current;

    // 버튼 토글
    var btn = document.getElementById('btn-'+matchId);
    if(btn){
      btn.textContent = '예약됨';
      btn.classList.remove('btn-primary');
      btn.classList.add('btn-success');
      btn.disabled = true;
    }

    // 메모리 데이터 갱신
    for (var i=0;i<ALL_MATCHES.length;i++){
      if(ALL_MATCHES[i].id === matchId){ ALL_MATCHES[i].current = out.current; break; }
    }
    alert('예약되었습니다!');
  }catch(e){
    alert('네트워크 오류: ' + e.message);
  }
}

// ---------- 구글 지도/플레이스 ----------
var map, placesService, infoWin;
var listEl = document.getElementById('placeList');

function showPlacesError(msg){
  var el = document.getElementById('placesError');
  el.style.display='block'; el.textContent = msg; console.error(msg);
}

function initApp(){
  if(navigator.geolocation){
    navigator.geolocation.getCurrentPosition(
      function(pos){ initMap(pos.coords.latitude, pos.coords.longitude); },
      function(){ initMap(37.5662952,126.9779451); },
      { enableHighAccuracy:true }
    );
  }else{
    initMap(37.5662952,126.9779451);
  }
}

function initMap(lat,lng){
  var center = new google.maps.LatLng(lat,lng);
  map = new google.maps.Map(document.getElementById('map'), {
    center:center, zoom:14, mapTypeControl:false, streetViewControl:false
  });
  infoWin = new google.maps.InfoWindow();
  new google.maps.Marker({
    position:center, map:map,
    label:{text:"내 위치", className:""},
    icon:{ path: google.maps.SymbolPath.CIRCLE, scale:6 }
  });

  placesService = new google.maps.places.PlacesService(map);
  searchFutsal(center);
}

function searchFutsal(center){
  listEl.innerHTML = "";
  var bounds = new google.maps.LatLngBounds();

  placesService.nearbySearch(
    { location:center, radius:3000, keyword:"풋살장" },
    function(results, status, pagination){
      if(status !== google.maps.places.PlacesServiceStatus.OK || !results){
        showPlacesError("주변 장소 검색에 실패했습니다. (Places API)");
        return;
      }
      results.forEach(function(place){
        addPlace(place, bounds);
      });
      map.fitBounds(bounds);
      if(pagination && pagination.hasNextPage){ pagination.nextPage(); }
    }
  );
}

function addPlace(place, bounds){
  var pos = place.geometry && place.geometry.location;
  if(!pos) return;

  var marker = new google.maps.Marker({ position:pos, map:map, title:place.name });

  marker.addListener('click', function(){
    var html =
      '<div style="padding:6px 8px;font-size:12px;">' +
        '<strong>' + place.name + '</strong><br>' +
        (place.vicinity || place.formatted_address || '') +
      '</div>';
    infoWin.setContent(html);
    infoWin.open(map, marker);

    // 1) 경기 필터링
    filterByVenue(place.name);
    document.getElementById('matchListBox').scrollIntoView({behavior:'smooth', block:'start'});

    // 2) 리뷰 패널 열기 + 로드
    openReviewPanel(place.name);
    loadPlaceReviews(place.name);
  });

  var li = document.createElement('li');
  li.className = "list-group-item place-item";
  li.innerHTML = '<strong>' + place.name + '</strong><br><small>' + (place.vicinity || '') + '</small>';
  li.onclick = function(){
    map.panTo(pos);
    google.maps.event.trigger(marker, 'click');
  };
  listEl.appendChild(li);

  bounds.extend(pos);
}

// ---------- 리뷰 패널 ----------
const reviewPanel = document.getElementById('reviewPanel');
const rvTitle = document.getElementById('rvPlaceTitle');
const rvCount = document.getElementById('rvCount');
const rvList  = document.getElementById('rvList');
const rvError = document.getElementById('rvError');

function openReviewPanel(placeName){
  rvTitle.textContent = placeName + ' 리뷰';
  rvCount.textContent = '';
  rvList.innerHTML = '';
  rvError.style.display = 'none';
  reviewPanel.style.display = 'block';
}
function hideReviewPanel(){
  reviewPanel.style.display = 'none';
}

async function loadPlaceReviews(placeName){
  try{
    const res = await fetch('review?action=listByPlace&place=' + encodeURIComponent(placeName));
    if(!res.ok){ throw new Error('HTTP ' + res.status); }
    const data = await res.json();

    rvList.innerHTML = '';
    rvCount.textContent = '총 ' + data.length + '개';

    if(!Array.isArray(data) || data.length===0){
      rvList.innerHTML = '<div class="text-muted">아직 이 장소의 리뷰가 없습니다.</div>';
      return;
    }
    data.forEach(function(r){
      const div = document.createElement('div');
      div.className = 'review-item';
      const star = r.rating ? ('★' + r.rating) : '';
      const name = (r.user == null ? '익명' : r.user);
      const content = (r.content || '').replace(/</g,'&lt;').replace(/>/g,'&gt;');
      const created = (r.createdAt || '');
      div.innerHTML =
        '<div><b>' + name + '</b> ' + star + '</div>' +
        '<div>' + content + '</div>' +
        '<div><small class="text-secondary">' + created + '</small></div>';
      rvList.appendChild(div);
    });
  }catch(err){
    rvError.style.display='block';
    rvError.textContent = '리뷰를 불러오지 못했습니다. (' + err.message + ')';
  }
}

// 구글 스크립트 로더
window.initApp = initApp;
</script>

<!-- 구글 지도 + Places -->
<script async defer src="https://maps.googleapis.com/maps/api/js?key=AIzaSyDaHgeNhzhPvhJu3RGyjkhXWhdeGD5ijXA&libraries=places&callback=initApp"></script>

<%@ include file="include/footer.jsp" %>
</body>
</html>