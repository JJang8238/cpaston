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

        body {
            background:#f5f7fa;
        }

        .page-wrap {
            max-width:1200px;
            margin:24px auto 40px;
            padding:0 16px;
        }

        .page-header-wrap {
            background:#ffffff;
            border-radius:18px;
            padding:20px 22px;
            box-shadow:0 4px 16px rgba(15,23,42,0.06);
            margin-bottom:18px;
        }

        .page-title {
            font-size:24px;
            font-weight:700;
            margin-bottom:4px;
        }

        .page-subtitle {
            font-size:14px;
            color:#6b7280;
        }

        /* 지도 카드 */
        .map-card {
            background:#ffffff;
            border-radius:18px;
            box-shadow:0 4px 18px rgba(15,23,42,0.08);
            padding:18px 18px 16px;
        }

        #map {
            width:100%;
            height:520px;
            min-height:420px;
            background:#fff;
            border-radius:14px;
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
            background:linear-gradient(180deg,#fff,#f8f9fa);
        }

        /* 하단 목록 카드 */
        .places-card {
            margin-top:18px;
            background:#ffffff;
            border-radius:18px;
            box-shadow:0 4px 16px rgba(15,23,42,0.06);
            padding:16px 18px 14px;
        }

        .places-card h5 {
            font-size:16px;
            font-weight:600;
            margin-bottom:10px;
        }

        #placesList .list-group-item {
            border:none;
            border-radius:10px;
            margin-bottom:6px;
            font-size:14px;
            cursor:pointer;
        }

        #placesList .list-group-item:hover {
            background:#eff6ff;
        }

        /* 리뷰 패널 (오른쪽 슬라이드) */
        #reviewPanel {
            position:fixed;
            top:0;
            right:0;
            width:380px;
            max-width:90vw;
            height:100vh;
            background:#ffffff;
            border-left:none;
            z-index:1000;
            padding:20px 18px 18px;
            overflow-y:auto;
            display:none;
            box-shadow:-6px 0 24px rgba(15,23,42,0.2);
            border-radius:16px 0 0 16px;
        }
        #reviewPanel .close-btn {
            position:absolute;
            top:16px;
            right:16px;
        }

        #rvPlaceTitle {
            font-size:17px;
            font-weight:700;
        }

        .review-item {
            border-bottom:1px solid #eaeaea;
            padding:10px 0;
            font-size:14px;
        }

        .review-item:last-child {
            border-bottom:none;
        }

        .rv-section-title {
            font-size:14px;
            font-weight:600;
        }
    </style>
</head>

<body>

<!-- 상단 네비는 기존 그대로 사용 -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container px-5">
        <a class="navbar-brand" href="<%=request.getContextPath()%>/main.jsp">볼피또</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse"
                data-bs-target="#navbarSupportedContent">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarSupportedContent">
            <ul class="navbar-nav ms-auto mb-2 mb-lg-0">
                <li class="nav-item"><a class="nav-link" href="<%=request.getContextPath()%>/main.jsp">홈</a></li>
                <li class="nav-item"><a class="nav-link" href="<%=request.getContextPath()%>/mypage.jsp">마이페이지</a></li>
                <li class="nav-item"><a class="nav-link" href="<%=request.getContextPath()%>/logout.jsp">로그아웃</a></li>
            </ul>
        </div>
    </div>
</nav>

<div class="page-wrap">

    <!-- 상단 제목 카드 -->
    <div class="page-header-wrap">
        <h2 class="page-title mb-1">내 주변 풋살장</h2>
        <p class="page-subtitle mb-0">현재 위치 기준으로 가까운 풋살장을 찾아보고, 리뷰와 경기 일정을 확인해 보세요.</p>
    </div>

    <!-- 지도 + 반경 / 버튼 카드 -->
    <div class="map-card mb-3">
        <div class="d-flex flex-wrap gap-2 mb-3">
            <select id="selRadius" class="form-select form-select-sm" style="width:140px">
                <option value="1000">반경 1km</option>
                <option value="2000" selected>반경 2km</option>
                <option value="3000">반경 3km</option>
                <option value="5000">반경 5km</option>
            </select>
            <button id="btnRelocate" class="btn btn-sm btn-outline-primary">현재 위치로</button>
            <button id="btnSearch" class="btn btn-sm btn-primary">이 위치에서 검색</button>
        </div>

        <div id="map"><div class="loading">내 위치를 확인하는 중...</div></div>
    </div>

    <!-- 하단 풋살장 목록 카드 -->
    <div id="placesListBox" class="places-card">
        <h5 class="mb-2">📍 지도에 표시된 풋살장 목록</h5>
        <ul id="placesList" class="list-group"></ul>
    </div>
</div>

<!-- 오른쪽 리뷰 / 일정 패널 -->
<aside id="reviewPanel">
    <button class="btn btn-sm btn-outline-secondary close-btn" onclick="hideReviewPanel()">닫기</button>

    <h5 id="rvPlaceTitle" class="mb-2 mt-4"></h5>

    <!-- 정보 / 리뷰 카드 -->
    <div class="card mb-3 border-0 shadow-sm">
        <div class="card-body">

            <img id="rvPlaceImage"
                 src="<%=request.getContextPath()%>/assets/img/field-default.png"
                 class="img-fluid rounded mb-3"
                 style="width:100%; height:160px; object-fit:cover;">

            <div class="text-muted small mb-2">주변 이용자들이 남긴 리뷰를 확인해 보세요.</div>

            <div class="mb-2 d-flex align-items-center">
                <span style="font-size:20px; color:#FFC107;">★</span>
                <span id="rvAvgRating" class="fw-bold ms-1">-</span>
                <span class="text-muted small ms-1">(리뷰 <span id="rvReviewCount">0</span>개)</span>
            </div>

            <hr>

            <h6 class="rv-section-title mb-2">리뷰 목록</h6>
            <div id="rvReviewList">
                <p class="text-muted mb-0">아직 리뷰가 없습니다.</p>
            </div>

        </div>
    </div>

    <!-- 경기 일정 카드 -->
    <div class="card border-0 shadow-sm">
        <div class="card-header fw-bold bg-white border-bottom-0">예정된 경기 일정</div>
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

// ✅ 명확히 선언(암묵 전역 방지)
let userMarkerImage = null;
let placeMarkerImage = null;

// 위치 옵션(정확도/타임아웃/캐시)
const GEO_OPTS = {
    enableHighAccuracy: true,
    timeout: 10000,
    maximumAge: 0
};

// 날짜 기본값 = 오늘
document.addEventListener("DOMContentLoaded", function() {
    const today = new Date().toISOString().split("T")[0];
    document.getElementById("matchDate").value = today;

    // 지도 로딩과 상관없이 버튼 이벤트를 먼저 바인딩
    document.getElementById("btnRelocate").addEventListener("click", relocateToMe);
    document.getElementById("btnSearch").addEventListener("click", searchFromCurrentMapCenter);
    document.getElementById("selRadius").addEventListener("change", () => {
        if (!userCenter) return;
        drawRadius();
        searchAround();
    });
});

/* 지도 초기화 */
function initAppKakao() {
    navigator.geolocation.getCurrentPosition(
        pos => createMap(pos.coords.latitude, pos.coords.longitude),
        err => {
            console.warn("📌 Geolocation failed on init:", err);
            // 실패 시 서울 시청 기본 좌표
            createMap(37.5665, 126.9780);
        },
        GEO_OPTS
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

    // 지도 마커 SVG
    const markerSize   = new kakao.maps.Size(24, 35);
    const markerOffset = new kakao.maps.Point(12, 35);

    const USER_MARKER_SVG =
        'data:image/svg+xml;charset=UTF-8,' +
        '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="35" viewBox="0 0 24 35">' +
        '<path fill="%23007bff" d="M12 0C6.5 0 2 4.5 2 10c0 7.5 10 15 10 25 0-10 10-17.5 10-25C22 4.5 17.5 0 12 0z"/>' +
        '<circle cx="12" cy="10" r="4" fill="%23ffffff"/></svg>';

    const PLACE_MARKER_SVG =
        'data:image/svg+xml;charset=UTF-8,' +
        '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="35" viewBox="0 0 24 35">' +
        '<path fill="%2334c759" d="M12 0C6.5 0 2 4.5 2 10c0 7.5 10 15 10 25 0-10 10-17.5 10-25C22 4.5 17.5 0 12 0z"/>' +
        '<circle cx="12" cy="10" r="4" fill="%23ffffff"/></svg>';

    userMarkerImage  = new kakao.maps.MarkerImage(USER_MARKER_SVG,  markerSize, {offset: markerOffset});
    placeMarkerImage = new kakao.maps.MarkerImage(PLACE_MARKER_SVG, markerSize, {offset: markerOffset});

    drawUserSpot();
    searchAround();
}

function drawUserSpot() {
    if (!userCenter || !kakaoMap) return;

    if (userMarker) userMarker.setMap(null);

    userMarker = new kakao.maps.Marker({
        position:new kakao.maps.LatLng(userCenter.lat, userCenter.lng),
        map:kakaoMap,
        image:userMarkerImage
    });

    drawRadius();
}

function drawRadius() {
    if (!userCenter || !kakaoMap) return;

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
    if (!kakaoPlaces || !userCenter) return;

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

    // 거리 계산
    const distKm = getDistance(userCenter.lat, userCenter.lng, lat, lng);
    const distText = distKm < 1
        ? Math.round(distKm * 1000) + "m"
        : distKm.toFixed(1) + "km";

    const marker = new kakao.maps.Marker({
        position:new kakao.maps.LatLng(lat, lng),
        map:kakaoMap,
        image:placeMarkerImage
    });

    markers.push(marker);

    // 리스트에 거리 포함
    const li = document.createElement("li");
    li.className = "list-group-item list-group-item-action";

    li.innerHTML =
        "<div class='d-flex justify-content-between align-items-center'>" +
            "<span>" + place.place_name + "</span>" +
            "<span class='badge bg-primary'>" + distText + "</span>" +
        "</div>";

    li.onclick = () => openReviewPanel(place);

    document.getElementById("placesList").appendChild(li);

    kakao.maps.event.addListener(marker, "click", () => {
        openReviewPanel(place);
    });
}

function openReviewPanel(place) {
    const placeName = place.place_name;
    currentPlaceName = placeName;

    document.getElementById("rvPlaceTitle").textContent = placeName;
    document.getElementById("reviewPanel").style.display = "block";

    const safeName = placeName.replace(/\s+/g, "");
    const img = document.getElementById("rvPlaceImage");
    img.src = "<%=request.getContextPath()%>/assets/img/" + safeName + ".png";

    img.onerror = function () {
        this.src = "<%=request.getContextPath()%>/assets/img/field-default.png";
    };

    loadReviews(placeName);
    loadMatches(placeName);
}

function loadReviews(placeName) {
    fetch("<%=request.getContextPath()%>/review?action=listByPlace&place=" + encodeURIComponent(placeName))
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

function loadMatches(placeName) {
    const date = document.getElementById("matchDate").value;

    fetch("<%=request.getContextPath()%>/reserve?action=matchesByPlace&place=" +
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
                } else if (m.joined) {
                    btn = "<button class='btn btn-sm btn-outline-danger ms-2' onclick='cancelReserve(" + m.id + ")'>취소하기</button>";
                } else if (m.current >= m.max) {
                    btn = "<span class='badge bg-secondary ms-2'>마감</span>";
                } else {
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
    params.append("action", "book");
    params.append("matchId", matchId);

    fetch("<%=request.getContextPath()%>/reserve", {
        method: "POST",
        headers: {
            "Content-Type": "application/x-www-form-urlencoded",
            "X-Requested-With": "XMLHttpRequest"
        },
        body: params,
        credentials: "include"   // ★ 쿠키(JSESSIONID) 포함
    })
    .then(res => res.json())
    .then(data => {
        if (data.ok) {
            alert("예약 완료!");
            loadMatches(currentPlaceName);
        } else {
            alert("예약 실패");
        }
    })
    .catch(err => {
        console.error("예약 오류:", err);
        alert("서버 오류가 발생했습니다.");
    });
}

function cancelReserve(matchId) {
    const params = new URLSearchParams();
    params.append("action", "cancel");
    params.append("matchId", matchId);

    fetch("<%=request.getContextPath()%>/reserve", {
        method: "POST",
        headers: {
            "Content-Type": "application/x-www-form-urlencoded",
            "X-Requested-With": "XMLHttpRequest"
        },
        body: params,
        credentials: "include"   // ★ 쿠키(JSESSIONID) 포함
    })
    .then(res => res.json())
    .then(data => {
        if (data.ok) {
            alert("예약 취소!");
            loadMatches(currentPlaceName);
        } else {
            alert("취소 실패");
        }
    })
    .catch(err => {
        console.error("취소 오류:", err);
        alert("서버 오류가 발생했습니다.");
    });
}

// 현재 위치로 버튼용
function relocateToMe() {
    if (!navigator.geolocation) {
        alert("이 브라우저는 위치 기능을 지원하지 않습니다.");
        return;
    }

    navigator.geolocation.getCurrentPosition(
        pos => {
            userCenter = {lat:pos.coords.latitude, lng:pos.coords.longitude};

            if (kakaoMap) {
                kakaoMap.setCenter(new kakao.maps.LatLng(userCenter.lat, userCenter.lng));
                drawUserSpot();
                searchAround();
            } else {
                console.log("지도 로딩 전 위치만 갱신:", userCenter);
            }
        },
        err => {
            console.warn("📌 Geolocation error:", err);

            switch (err.code) {
                case err.PERMISSION_DENIED:
                    alert("위치 권한이 거부됐어요. 브라우저 주소창 옆 🔒/📍에서 위치 허용으로 바꿔줘!");
                    break;
                case err.POSITION_UNAVAILABLE:
                    alert("현재 위치 정보를 가져올 수 없어요. GPS/네트워크 상태를 확인해줘!");
                    break;
                case err.TIMEOUT:
                    alert("위치 요청 시간이 초과됐어요. 다시 눌러줘!");
                    break;
                default:
                    alert("위를 가져올 수 없습니다.");
            }
        },
        GEO_OPTS
    );
}

// “이 위치에서 검색” 버튼용
function searchFromCurrentMapCenter() {
    if (!kakaoMap) {
        alert("지도가 아직 로딩 중이야. 잠깐만 기다렸다가 다시 눌러줘!");
        return;
    }
    const c = kakaoMap.getCenter();
    userCenter = { lat: c.getLat(), lng: c.getLng() };
    drawUserSpot();
    searchAround();
}

function hideReviewPanel(){
    document.getElementById("reviewPanel").style.display = "none";
}

// 거리 계산 함수
function getDistance(lat1, lon1, lat2, lon2) {
    function toRad(value) {
        return value * Math.PI / 180;
    }

    const R = 6371; // 지구 반지름 km
    const dLat = toRad(lat2 - lat1);
    const dLon = toRad(lon2 - lon1);
    const a =
        Math.sin(dLat/2) * Math.sin(dLat/2) +
        Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
        Math.sin(dLon/2) * Math.sin(dLon/2);

    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    const d = R * c;  // km

    return d;
}
</script>

<script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=f802c143efc8e04c44d5cbc892fe3198&libraries=services&autoload=false"></script>
<script> kakao.maps.load(initAppKakao); </script>

</body>
</html>
