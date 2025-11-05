<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    request.setCharacterEncoding("UTF-8");

    String matchTitle = request.getParameter("matchTitle");
    String rating = request.getParameter("rating");
    String content = request.getParameter("content");
    String writer = request.getParameter("writer");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>리뷰 저장</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container mt-5">
    <div class="card p-4 shadow-sm">
        <h3 class="mb-3 text-primary fw-bold">리뷰 임시 저장 완료</h3>
        <p>아래 내용이 정상적으로 전달되었습니다. (DB 연결 전이므로 실제 저장은 되지 않습니다.)</p>
        <ul class="list-group">
            <li class="list-group-item"><strong>경기명:</strong> <%= matchTitle %></li>
            <li class="list-group-item"><strong>평점:</strong> <%= rating %>점</li>
            <li class="list-group-item"><strong>작성자:</strong> <%= writer %></li>
            <li class="list-group-item"><strong>리뷰 내용:</strong><br><%= content %></li>
        </ul>
        <div class="mt-4">
            <a href="review.jsp" class="btn btn-secondary">리뷰 목록으로 돌아가기</a>
            <a href="main.jsp" class="btn btn-primary">메인으로 가기</a>
        </div>
    </div>
</div>
</body>
</html>
