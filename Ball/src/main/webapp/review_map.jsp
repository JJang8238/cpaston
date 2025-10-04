<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="dao.MatchDAO, dto.Match" %>
<%
    MatchDAO matchDAO = new MatchDAO();
    List<Match> matchList = matchDAO.getTodayMatches(); // 오늘 경기
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>풋살장 리뷰 작성</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

  <style>
    body {
      background-color: #f8f9fa;
      display: flex;
      height: 100vh;
      margin: 0;
    }
    #map {
      flex: 2;
      height: 100%;
    }
    #review-panel {
      flex: 1;
      background: white;
      border-left: 1px solid #ddd;
      padding: 20px;
      overflow-y: auto;
      display: none; /* 마커 클릭 전엔 숨김 */
    }
    .review-item {
      border-bottom: 1px solid #e5e5e5;
      padding: 8px 0;
    }
  </style>
</head>
<body>

  <div id="map"></div>

  <!-- 오른쪽 리뷰 패널 -->
  <div id="review-panel">
    <h5 id="place-name" class="mb-3"></h5>

    <div id="existing-reviews"></div>

    <hr>
    <form id="review-form">
      <div class="mb-2">
        <textarea id="review-text" class="form-control" rows="3" placeholder="리뷰를 작성하세요..."></textarea>
      </div>
      <button type="submit" class="btn btn-primary w-100">리뷰 작성</button>
    </form>
  </div>

  <!-- Google Maps API -->
  <script
    src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCZ3fDFHzrvVp04VSbGjD8Yd8N9PDNiTPM&libraries=places&language=ko"
    async defer></script>

  <script>
    let map;
    let reviewPanel = document.getElementById('review-panel');
    let placeName = document.getElementById('place-name');
    let existingReviews = document.getElementById('existing-reviews');
    let reviewForm = document.getElementById('review-form');
    let currentPlace = null;

    function initMap() {
      map = new google.maps.Map(document.getElementById("map"), {
        center: { lat: 37.626, lng: 127.062 }, // 녹번역 근처
        zoom: 15,
      });

      // 예시 마커들 (DB의 경기 장소와 연결 가능)
      const places = [
        { name: "서울 풋살장", lat: 37.626, lng: 127.062 },
        { name: "녹번 풋살파크", lat: 37.628, lng: 127.060 }
      ];

      places.forEach(place => {
        const marker = new google.maps.Marker({
          position: { lat: place.lat, lng: place.lng },
          map: map,
          title: place.name
        });

        marker.addListener('click', () => {
          currentPlace = place;
          placeName.textContent = place.name;
          loadReviews(place.name);
          reviewPanel.style.display = 'block';
        });
      });
    }

    window.initMap = initMap;

    // 임시 리뷰 저장소 (실제로는 AJAX로 서버와 통신)
    const reviewStorage = {};

    reviewForm.addEventListener('submit', (e) => {
      e.preventDefault();
      if (!currentPlace) return;

      const text = document.getElementById('review-text').value.trim();
      if (text === '') return;

      if (!reviewStorage[currentPlace.name]) reviewStorage[currentPlace.name] = [];
      reviewStorage[currentPlace.name].push(text);

      document.getElementById('review-text').value = '';
      loadReviews(currentPlace.name);
    });

    function loadReviews(placeNameStr) {
      existingReviews.innerHTML = '';
      const reviews = reviewStorage[placeNameStr] || [];
      reviews.forEach(r => {
        const div = document.createElement('div');
        div.className = 'review-item';
        div.textContent = r;
        existingReviews.appendChild(div);
      });
    }
  </script>
</body>
</html>
