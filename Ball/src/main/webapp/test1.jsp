<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>네이버 지도 테스트</title>
    <script src="https://oapi.map.naver.com/openapi/v3/maps.js?ncpClientId=z61duuh6wp"></script>
</head>
<body>
    <div id="map" style="width:100%; height:400px;"></div>
    <script>
        alert("지도 스크립트 실행 확인");
        var map = new naver.maps.Map('map', {
            center: new naver.maps.LatLng(37.5665, 126.9780),
            zoom: 10
        });
    </script>
</body>
</html>
