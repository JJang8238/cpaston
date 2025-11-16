<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>내 주변 풋살장</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        :root { --border:#e5e5e5; }
        body { background:#f8f9fa; }
        .wrap { max-width:1080px; margin:24px auto; padding:0 16px; }

        #map {
            width:100%;
            height:520px;
            min-height:420px;
            background:#fff;
            border:1px solid var(--border);
            border-radius:12px;
            overflow:hidden;
            position:relative;
        }

        #map .loading {
            position:absolute;
            inset:0;
            display:flex;
            align-items:center;
            justify-content:center;
            font-weight:600;
            color:#6c757d;
            background:linear-gradient(180deg,#fff, #f8f9fa);
        }

        #reviewPanel {
            position:fixed;
            top:0;
            right:0;
            width:380px;
            max-width:90vw;
            height:100vh;
            background:#fff;
            border-left:1px solid var(--border);
            z-index:1000;
            padding:16px;
            overflow-y:auto;
            display:none;
        }
        #reviewPanel .close-btn {
            position:absolute;
            top:12px;
            right:12px;
        }

        .review-item {
            border-bottom:1px solid #eaeaea;
            padding:10px 0;
        }
    </style>
</head>

<body>

<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container px-5">
        <a class="navbar-brand" href="/Ball/main.jsp">볼피또</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse"
                data-bs-target="#navbarSupportedContent">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarSupportedContent">
            <ul class="navbar-nav ms-auto mb-2 mb-lg-0">
                <li class="nav-item"><a class="nav-link" href="/Ball/main.jsp">홈</a></li>
                <li class="nav-item"><a class="nav-link" href="/Ball/mypage.jsp">마이페이지</a></li>
                <li class="nav-item"><a class="nav-link" href="/Ball/logout.jsp">로그아웃</a></li>
            </ul>
        </div>
    </div>
</nav>

<div class="wrap">
    <h2 class="my-3">내 주변 풋살장</h2>

    <div class="d-flex gap-2 mb-3">
        <select id="selRadius" class="form-select form-select-sm" style="width:120px">
            <option value="1000">반경 1km</option>
            <option value="2000" selected>반경 2km</option>
            <option value="3000">반경 3km</option>
            <option value="5000">반경 5km</option>
        </select>
        <button id="btnRelocate" class="btn btn-sm btn-outline-primary">현재 위치로</button>
        <button id="btnSearch" class="btn btn-sm btn-primary">이 위치에서 검색</button>
    </div>

    <div id="map"><div class="loading">내 위치를 확인하는 중...</div></div>

    <div id="placesListBox" class="mt-4">
        <h5>📍 지도에 표시된 풋살장 목록</h5>
        <ul id="placesList" class="list-group"></ul>
    </div>
</div>

<!-- 리뷰 패널 (리뷰 작성 영역 없음 / 조회만) -->
<aside id="reviewPanel">
    <button class="btn btn-sm btn-outline-secondary close-btn" onclick="hideReviewPanel()">닫기</button>

    <h5 id="rvPlaceTitle" class="mb-2 mt-3"></h5>

    <div class="card mb-3">
        <div class="card-body">

            <img id="rvPlaceImage" src="/Ball/assets/img/field-default.jpg"
                 class="img-fluid rounded mb-3"
                 style="width:100%; height:160px; object-fit:cover;">

            <div class="text-muted small mb-2">
                주변 이용자들이 남긴 리뷰를 확인해 보세요.
            </div>

            <div class="mb-2">
                <span style="font-size:20px; color:#FFC107;">★</span>
                <span id="rvAvgRating" class="fw-bold ms-1">-</span>
                <span class="text-muted small ms-1">(리뷰 <span id="rvReviewCount">0</span>개)</span>
            </div>

            <hr>

            <h6 class="fw-bold mb-2">리뷰 목록</h6>
            <div id="rvReviewList">
                <p class="text-muted mb-0">아직 리뷰가 없습니다.</p>
            </div>

        </div>
    </div>

    <div class="card">
        <div class="card-header fw-bold">예정된 경기 일정</div>
        <div class="card-body" id="rvMatches">
            <input type="date" id="matchDate" class="form-control form-control-sm mb-3">
            <p class="text-muted mb-0">예정된 경기가 없습니다.</p>
        </div>
    </div>
</aside>


<script>
let kakaoMap, kakaoPlaces, userMarker, radiusCircle;
let userCenter = null;
let markers = [];
let currentPlaceName = null;

// 🔹 마커 이미지(색 다른 SVG)를 담아둘 전역 변수
let userMarkerImage = null;
let placeMarkerImage = null;

/* 날짜 기본값 = 오늘 */
document.addEventListener("DOMContentLoaded", function() {
    const today = new Date().toISOString().split("T")[0];
    document.getElementById("matchDate").value = today;
});

/* 지도 초기화 */
function initAppKakao() {
    navigator.geolocation.getCurrentPosition(
        pos => createMap(pos.coords.latitude, pos.coords.longitude),
        () => createMap(37.5665, 126.9780)
    );
}

function createMap(lat, lng) {
    userCenter = {lat, lng};

    const mapContainer = document.getElementById("map");
    const loading = mapContainer.querySelector(".loading");
    if (loading) loading.remove();

    kakaoMap = new kakao.maps.Map(mapContainer, {
        center:new kakao.maps.LatLng(lat, lng),
        level:5
    });

    kakaoPlaces = new kakao.maps.services.Places();

    // 🔹 SVG 기반 마커 이미지 생성(이미지 파일 업로드 없이 색만 다른 마커)
    const markerSize   = new kakao.maps.Size(24, 35);
    const markerOffset = new kakao.maps.Point(12, 35);

    // 내 위치(파란색)
    const USER_MARKER_SVG =
        'data:image/svg+xml;charset=UTF-8,' +
        '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="35" viewBox="0 0 24 35">' +
        '<path fill="%23007bff" d="M12 0C6.5 0 2 4.5 2 10c0 7.5 10 15 10 25 0-10 10-17.5 10-25C22 4.5 17.5 0 12 0z"/>' +
        '<circle cx="12" cy="10" r="4" fill="%23ffffff"/></svg>';

    // 풋살장(초록색)
    const PLACE_MARKER_SVG =
        'data:image/svg+xml;charset=UTF-8,' +
        '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="35" viewBox="0 0 24 35">' +
        '<path fill="%2334c759" d="M12 0C6.5 0 2 4.5 2 10c0 7.5 10 15 10 25 0-10 10-17.5 10-25C22 4.5 17.5 0 12 0z"/>' +
        '<circle cx="12" cy="10" r="4" fill="%23ffffff"/></svg>';

    userMarkerImage  = new kakao.maps.MarkerImage(USER_MARKER_SVG,  markerSize, {offset: markerOffset});
    placeMarkerImage = new kakao.maps.MarkerImage(PLACE_MARKER_SVG, markerSize, {offset: markerOffset});

    drawUserSpot();
    searchAround();

    document.getElementById("btnRelocate").onclick = relocateToMe;
    document.getElementById("btnSearch").onclick = searchAround;
    document.getElementById("selRadius").onchange = () => {
        drawRadius();
        searchAround();
    };
}

function drawUserSpot() {
    if (userMarker) userMarker.setMap(null);

    userMarker = new kakao.maps.Marker({
        position:new kakao.maps.LatLng(userCenter.lat, userCenter.lng),
        map:kakaoMap,
        image:userMarkerImage   // 🔹 파란색 마커
    });

    drawRadius();
}

function drawRadius() {
    const r = Number(document.getElementById("selRadius").value);
    if (radiusCircle) radiusCircle.setMap(null);

    radiusCircle = new kakao.maps.Circle({
        center:new kakao.maps.LatLng(userCenter.lat, userCenter.lng),
        radius:r,
        strokeWeight:2,
        strokeColor:"#4a90e2",
        fillColor:"#4a90e2",
        fillOpacity:0.1
    });
    radiusCircle.setMap(kakaoMap);
}

/* 주변 풋살장 검색 */
function clearPlaceMarkers() {
    markers.forEach(m => m.setMap(null));
    markers = [];
    document.getElementById("placesList").innerHTML = "";
}

function searchAround() {
    clearPlaceMarkers();

    const r = Number(document.getElementById("selRadius").value);

    kakaoPlaces.keywordSearch(
        "풋살장",
        (data, status) => {
            if (status !== kakao.maps.services.Status.OK) return;
            data.slice(0,15).forEach(place => addPlace(place));
        },
        {
            location:new kakao.maps.LatLng(userCenter.lat, userCenter.lng),
            radius:r,
            sort:kakao.maps.services.SortBy.DISTANCE
        }
    );
}

function addPlace(place) {
    const lat = parseFloat(place.y);
    const lng = parseFloat(place.x);

    const marker = new kakao.maps.Marker({
        position:new kakao.maps.LatLng(lat, lng),
        map:kakaoMap,
        image:placeMarkerImage   // 🔹 초록색 마커
    });

    markers.push(marker);

    const li = document.createElement("li");
    li.className = "list-group-item list-group-item-action";
    li.textContent = place.place_name;
    li.onclick = () => openReviewPanel(place.place_name);

    document.getElementById("placesList").appendChild(li);

    kakao.maps.event.addListener(marker, "click", () => {
        openReviewPanel(place.place_name);
    });
}

function openReviewPanel(placeName) {
    currentPlaceName = placeName;
    document.getElementById("rvPlaceTitle").textContent = placeName;
    document.getElementById("reviewPanel").style.display = "block";

    loadReviews(placeName);
    loadMatches(placeName);
}

/* 리뷰 불러오기 */
function loadReviews(placeName) {
    fetch("/Ball/review?action=listByPlace&place=" + encodeURIComponent(placeName))
        .then(res => res.json())
        .then(data => {

            document.getElementById("rvAvgRating").textContent =
                Number(data.avgRating || 0).toFixed(1);
            document.getElementById("rvReviewCount").textContent = data.count;

            const box = document.getElementById("rvReviewList");
            const list = data.reviews || [];

            if (list.length === 0) {
                box.innerHTML = "<p class='text-muted mb-0'>아직 리뷰가 없습니다.</p>";
                return;
            }

            window.fullReviewList = list;

            const firstFive = list.slice(0,5);
            box.innerHTML = renderReviewItems(firstFive);

            if (list.length > 5) {
                box.innerHTML +=
                    "<button class='btn btn-sm btn-outline-primary w-100 mt-2' onclick='showAllReviews()'>" +
                    "더 보기 (" + (list.length - 5) + "개)</button>";
            }
        });
}

function renderReviewItems(list) {
    let html = "";

    list.forEach(r => {
        let stars = "★".repeat(r.rating);

        html +=
            "<div class='review-item'>" +
                "<div><span style='color:#FFC107;'>" + stars + "</span>" +
                "<span class='text-muted ms-1 small'>(" + r.rating + ")</span></div>" +
                "<div class='small text-muted mb-1'>" + r.author + " · " + r.createdAt + "</div>" +
                "<div>" + r.content + "</div>" +
            "</div>";
    });

    return html;
}

function showAllReviews() {
    const list = window.fullReviewList;
    const box = document.getElementById("rvReviewList");

    box.innerHTML = renderReviewItems(list);
    box.innerHTML +=
        "<button class='btn btn-sm btn-outline-secondary w-100 mt-2' onclick='collapseReviews()'>접기</button>";
}

function collapseReviews() {
    const list = window.fullReviewList;
    const box = document.getElementById("rvReviewList");

    box.innerHTML = renderReviewItems(list.slice(0,5));
}

/* 경기 일정 */
function loadMatches(placeName) {
    const date = document.getElementById("matchDate").value;

    fetch("/Ball/reserve?action=matchesByPlace&place=" +
        encodeURIComponent(placeName) + "&date=" + date)
        .then(res => res.json())
        .then(list => {

            const box = document.getElementById("rvMatches");

            if (!list || list.length === 0) {
                box.innerHTML =
                    "<input type='date' id='matchDate' class='form-control form-control-sm mb-3' value='" + date + "'>" +
                    "<p class='text-muted mb-0'>예정된 경기가 없습니다.</p>";
                return;
            }

            let html =
                "<input type='date' id='matchDate' class='form-control form-control-sm mb-3' " +
                "value='" + date + "' onchange='loadMatches(currentPlaceName)'>";

            list.forEach(m => {

                let btn = "";

                if (m.canceled) {
                    btn = "<span class='badge bg-danger ms-2'>취소됨</span>";
                }
                else if (m.joined) {
                    btn = "<button class='btn btn-sm btn-outline-danger ms-2' onclick='cancelReserve(" + m.id + ")'>취소하기</button>";
                }
                else if (m.current >= m.max) {
                    btn = "<span class='badge bg-secondary ms-2'>마감</span>";
                }
                else {
                    btn = "<button class='btn btn-sm btn-primary ms-2' onclick='reserveMatch(" + m.id + ")'>예약하기</button>";
                }

                html +=
                    "<div class='mb-2'>" +
                        "🕒 " + m.time + " | " + m.current + " / " + m.max +
                        " " + btn +
                    "</div>";
            });

            box.innerHTML = html;
        });
}

function reserveMatch(matchId) {
    const params = new URLSearchParams();
    params.append("action","book");
    params.append("matchId",matchId);

    fetch("/Ball/reserve", {
        method:"POST",
        body:params
    })
    .then(res=>res.json())
    .then(data=>{
        if(data.ok){
            alert("예약 완료!");
            loadMatches(currentPlaceName);
        }
        else alert("예약 실패");
    });
}

function cancelReserve(matchId) {
    const params = new URLSearchParams();
    params.append("action","cancel");
    params.append("matchId",matchId);

    fetch("/Ball/reserve", {
        method:"POST",
        body:params
    })
    .then(res=>res.json())
    .then(data=>{
        if(data.ok){
            alert("예약 취소!");
            loadMatches(currentPlaceName);
        }
        else alert("취소 실패");
    });
}

function relocateToMe() {
    navigator.geolocation.getCurrentPosition(
        pos => {
            userCenter = {lat:pos.coords.latitude, lng:pos.coords.longitude};
            kakaoMap.setCenter(new kakao.maps.LatLng(userCenter.lat, userCenter.lng));
            drawUserSpot();
            searchAround();
        },
        () => alert("위치를 가져올 수 없습니다")
    );
}

function hideReviewPanel(){
    document.getElementById("reviewPanel").style.display = "none";
}
</script>

<script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=f802c143efc8e04c44d5cbc892fe3198&libraries=services&autoload=false"></script>
<script> kakao.maps.load(initAppKakao); </script>

</body>
</html>
