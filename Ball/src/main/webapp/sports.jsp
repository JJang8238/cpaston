<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.time.LocalTime, java.util.List" %>
<%@ page import="dao.MatchDAO, dto.Match" %>
<%@ include file="include/header.jsp" %>

<%
    // 경기 데이터 가져오기
    MatchDAO matchDAO = new MatchDAO();
    List<Match> matchList = matchDAO.getTodayMatches();
    LocalTime now = LocalTime.now();

    // 네이버 지도용 Client ID
    String MAP_CLIENT_ID = "z61duuh6wp";  // NCP 콘솔에서 발급받은 Client ID
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>스포츠 예약 및 주변 풋살장</title>
    <style>
        #map { width: 100%; height: 400px; border: 1px solid #e5e5e5; margin-top: 20px; }
        .place-item { cursor: pointer; padding: 10px; border-bottom: 1px solid #eee; }
        .place-item:hover { background-color: #f9f9f9; }
        .error-box { color:#c0392b; background:#fdecea; border:1px solid #f5c6cb; padding:10px; border-radius:6px; margin-top:10px; }
    </style>
    <script src="https://oapi.map.naver.com/openapi/v3/maps.js?ncpClientId=z61duuh6wp&submodules=geocoder"></script>
</head>
<body>
<div class="container py-4">
    <h2 class="mb-4">오늘의 경기 예약 현황</h2>
    <div class="list-group mb-5">
        <%
            boolean hasFutureMatch = false;
            for (Match match : matchList) {
                if (match.getMatchTime().isAfter(now)) {
                    hasFutureMatch = true;
        %>
            <div class="list-group-item d-flex justify-content-between align-items-center">
                <div>
                    <h5 class="mb-1"><%= match.getMatchTime() %> 경기</h5>
                    <small><%= match.getLocation() %> | 인원: <%= match.getCurrentPlayers() %> / <%= match.getMaxPlayers() %></small>
                </div>
                <% if (match.getCurrentPlayers() < 12) { %>
                    <span class="badge bg-danger rounded-pill">경기 취소</span>
                <% } else { %>
                    <span class="badge bg-success rounded-pill">예약중</span>
                <% } %>
            </div>
        <%
                }
            }
            if (!hasFutureMatch) {
        %>
            <div class="list-group-item text-muted">
                현재 예약 가능한 경기가 없습니다.
            </div>
        <%
            }
        %>
    </div>

    <!-- 내 주변 풋살장 -->
    <h2 class="mb-3">내 주변 풋살장</h2>
    <div id="map"></div>
    <div id="placesError" class="error-box" style="display:none;"></div>
    <ul id="placeList" class="list-group list-group-flush mt-3"></ul>
</div>

<script>
let map;

function showError(msg) {
    const el = document.getElementById('placesError');
    el.style.display = 'block';
    el.textContent = msg;
    console.error(msg);
}

// 현재 위치 기반 지도
if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(
        pos => {
            const lat = pos.coords.latitude;
            const lng = pos.coords.longitude;
            initMap(lat, lng);
            searchFutsalPlaces(lat, lng);
        },
        err => {
            showError('위치 정보를 가져올 수 없어 기본 위치(서울시청)로 검색합니다.');
            const lat = 37.5662952, lng = 126.9779451;
            initMap(lat, lng);
            searchFutsalPlaces(lat, lng);
        },
        { enableHighAccuracy: true }
    );
} else {
    showError('이 브라우저는 위치 정보를 지원하지 않습니다.');
    const lat = 37.5662952, lng = 126.9779451;
    initMap(lat, lng);
    searchFutsalPlaces(lat, lng);
}

function initMap(lat, lng) {
    map = new naver.maps.Map('map', {
        center: new naver.maps.LatLng(lat, lng),
        zoom: 14
    });

    new naver.maps.Marker({
        position: new naver.maps.LatLng(lat, lng),
        map: map,
        icon: { content: `<div style="background:#2ecc71;color:#fff;padding:3px 5px;border-radius:4px;font-size:11px;">내 위치</div>` }
    });
}

async function searchFutsalPlaces(lat, lng) {
    const url = "searchPlaces.jsp?query=" + encodeURIComponent('풋살장');
    try {
        const res = await fetch(url);
        const data = await res.json();
        if (!res.ok || data.errorMessage) {
            showError("검색 실패: " + (data.errorMessage || "알 수 없는 오류"));
            return;
        }
        renderPlaces(data.items || []);
    } catch (e) {
        showError("fetch 중 오류: " + e.message);
    }
}

function renderPlaces(items) {
    const listEl = document.getElementById('placeList');
    listEl.innerHTML = "";
    const bounds = new naver.maps.LatLngBounds();

    if (!items.length) {
        listEl.innerHTML = '<li class="list-group-item text-muted">주변 풋살장을 찾지 못했습니다.</li>';
        return;
    }

    items.forEach(p => {
        const tm128 = new naver.maps.Point(parseFloat(p.mapx), parseFloat(p.mapy));
        const latlng = naver.maps.TransCoord.fromTM128ToLatLng(tm128);

        const marker = new naver.maps.Marker({ position: latlng, map: map });
        const info = new naver.maps.InfoWindow({
            content: '<div style="padding:8px 10px;font-size:12px;">'
                    + '<strong>' + stripTags(p.title) + '</strong><br>'
                    + (p.roadAddress || p.address || '') + '<br>'
                    + (p.telephone ? '전화: ' + p.telephone : '')
                    + '</div>'
        });

        naver.maps.Event.addListener(marker, 'mouseover', () => info.open(map, marker));
        naver.maps.Event.addListener(marker, 'mouseout', () => info.close());

        const li = document.createElement('li');
        li.className = "list-group-item place-item";
        li.innerHTML = '<strong>' + stripTags(p.title) + '</strong><br>'
            + '<small>' + (p.roadAddress || p.address || '') + '</small>'
            + (p.telephone ? '<br><small>전화: ' + p.telephone + '</small>' : '');
        li.onclick = () => { map.panTo(latlng); info.open(map, marker); };
        listEl.appendChild(li);
        bounds.extend(latlng);
    });

    // bounds.isEmpty() 오류 수정
    try {
        map.fitBounds(bounds);
    } catch (e) {
        console.warn("fitBounds 실행 오류:", e);
    }
}

function stripTags(str) {
    return (str || "").replace(/<\/?[^>]+(>|$)/g, "");
}
</script>
<%@ include file="include/footer.jsp" %>
</body>
</html>
