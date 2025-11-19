<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="dto.User" %>
<%
    Object _loginObj = session.getAttribute("loginUser");
    if (_loginObj == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    // dto.User일 수도 있고, 문자열일 수도 있으니 모두 대비
    User loginUser = null;
    String displayName = null;

    if (_loginObj instanceof User) {
        loginUser = (User) _loginObj;
        try {
            displayName = (loginUser.getName() != null && !loginUser.getName().isEmpty())
                          ? loginUser.getName()
                          : "사용자";
        } catch (Exception ignore) {
            displayName = "사용자";
        }
    } else {
        displayName = String.valueOf(_loginObj); // 예: "admin"
    }

    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>메인 페이지</title>
    <!-- Favicon -->
    <link rel="icon" type="image/x-icon" href="<%=ctx%>/assets/favicon.ico" />
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link href="<%=ctx%>/css/styles.css" rel="stylesheet" />
</head>
<body>

<!-- ✅ 네비게이션 -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container px-5">
        <a class="navbar-brand" href="<%=ctx%>/main.jsp">볼피또</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse"
                data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent"
                aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarSupportedContent">
            <ul class="navbar-nav ms-auto mb-2 mb-lg-0">
                <li class="nav-item">
                    <!-- 🔁 방탄 출력: dto.User든 문자열이든 안전 -->
                    <span class="nav-link disabled"><%= displayName %>님 환영합니다</span>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="<%=ctx%>/main.jsp">홈</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="<%=ctx%>/mypage.jsp">마이페이지</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="<%=ctx%>/logout.jsp">로그아웃</a>
                </li>
            </ul>
        </div>
    </div>
</nav>

<!-- ✅ 메인 컨텐츠 -->
<div class="container px-4 px-lg-5">

    <!-- Hero Section -->
    <div class="row gx-4 gx-lg-5 align-items-center my-5">
        <div class="col-lg-7">
            <img class="img-fluid rounded mb-4 mb-lg-0"
                 src="<%=ctx%>/assets/img/football.png" alt="플랩풋볼 메인 이미지" />
        </div>
        <div class="col-lg-5">
            <h1 class="fw-bold">우리의 운동 플랫폼</h1>
            <p class="text-muted">이 사이트는 경기 매칭 기능을 중심으로 제공합니다.</p>
            <a class="btn btn-primary" href="<%=ctx%>/sports.jsp">지금 참여하기</a>
        </div>
    </div>

    <!-- 공지 -->
    <div class="my-5 p-3 bg-secondary text-white text-center rounded">
        심한 욕설, 불법 행위 등을 금지합니다.
    </div>

    <!-- 서비스 카드 -->
    <div class="row text-center mb-5">
        <div class="col-md-4">
            <div class="card h-100 shadow-sm">
                <div class="card-body">
                    <h3 class="mb-2">경기 매칭</h3>
                    <p class="text-muted">경기를 뛰고 싶을 때! 원하는 지역에서 매칭을 손쉽게!</p>
                    <a href="<%=ctx%>/sports.jsp" class="btn btn-primary">자세히 보기</a>
                </div>
            </div>
        </div>
        <div class="col-md-4 mt-4 mt-md-0">
            <div class="card h-100 shadow-sm">
                <div class="card-body">
                    <h3 class="mb-2">커뮤니티</h3>
                    <p class="text-muted">같은 관심사를 가진 사람들과 소통하거나 모임을 만들어요.</p>
                    <a href="<%=ctx%>/community.jsp" class="btn btn-outline-primary">자세히 보기</a>
                </div>
            </div>
        </div>
        <div class="col-md-4 mt-4 mt-md-0">
            <div class="card h-100 shadow-sm">
                <div class="card-body">
                    <h3 class="mb-2">리뷰</h3>
                    <p class="text-muted">참여했던 경기/모임에 대해 자유롭게 리뷰하고 평가해요.</p>
                    <a href="<%=ctx%>/review.jsp" class="btn btn-outline-primary">자세히 보기</a>
                </div>
            </div>
        </div>
    </div>

    <!-- 오늘의 경기 예약 현황 -->
    <h2 class="fw-bold mb-3">오늘의 경기 예약 현황</h2>
    <div class="list-group mb-5 shadow-sm">
        <a href="#" class="list-group-item list-group-item-action d-flex justify-content-between align-items-center">
            <div>
                <div class="h5 mb-1">12:00 경기</div>
                <small class="text-muted">서울 풋살장 | 인원: 10 / 18</small>
            </div>
            <span class="badge bg-danger rounded-pill px-3 py-2">경기 취소</span>
        </a>

        <a href="#" class="list-group-item list-group-item-action d-flex justify-content-between align-items-center">
            <div>
                <div class="h5 mb-1">14:00 경기</div>
                <small class="text-muted">서울 풋살장 | 인원: 15 / 18</small>
            </div>
            <span class="badge bg-success rounded-pill px-3 py-2">예약중</span>
        </a>

        <a href="#" class="list-group-item list-group-item-action d-flex justify-content-between align-items-center">
            <div>
                <div class="h5 mb-1">16:00 경기</div>
                <small class="text-muted">서울 풋살장 | 인원: 18 / 18</small>
            </div>
            <span class="badge bg-success rounded-pill px-3 py-2">예약중</span>
        </a>

        <a href="#" class="list-group-item list-group-item-action d-flex justify-content-between align-items-center">
            <div>
                <div class="h5 mb-1">18:00 경기</div>
                <small class="text-muted">서울 풋살장 | 인원: 8 / 18</small>
            </div>
            <span class="badge bg-danger rounded-pill px-3 py-2">경기 취소</span>
        </a>

        <a href="#" class="list-group-item list-group-item-action d-flex justify-content-between align-items-center">
            <div>
                <div class="h5 mb-1">20:00 경기</div>
                <small class="text-muted">서울 풋살장 | 인원: 12 / 18</small>
            </div>
            <span class="badge bg-success rounded-pill px-3 py-2">예약중</span>
        </a>
    </div>

</div>

<!-- Footer -->
<footer class="py-5 bg-dark">
    <div class="container px-4 px-lg-5">
        <p class="m-0 text-center text-white">Copyright &copy; 볼피또 2025</p>
    </div>
</footer>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="<%=ctx%>/js/scripts.js"></script>

</body>
</html>
