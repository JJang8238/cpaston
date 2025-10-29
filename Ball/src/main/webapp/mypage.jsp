<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="dto.User" %>
<%
    // --- 로그인 가드 + 방탄 처리 (B안 컨셉)
    Object _loginObj = session.getAttribute("loginUser");
    if (_loginObj == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    User loginUser = null;
    String displayName = null;

    if (_loginObj instanceof User) {
        loginUser = (User) _loginObj;
        try {
            displayName = (loginUser.getName() != null && !loginUser.getName().isEmpty())
                          ? loginUser.getName()
                          : "사용자";
        } catch (Exception ignore) { displayName = "사용자"; }
    } else {
        displayName = String.valueOf(_loginObj); // 예: "admin"
    }

    String ctx = request.getContextPath();

    // --- 안전하게 필드 읽기 (dto.User일 때만 시도)
    String fUsername = "-";
    String fName     = displayName;
    String fEmail    = "-";
    String fRole     = "-";
    String fProfile  = null; // 이미지 경로 (없으면 기본 이미지 사용)

    if (loginUser != null) {
        try { if (loginUser.getUsername() != null) fUsername = loginUser.getUsername(); } catch (Exception ignore) {}
        try { if (loginUser.getEmail()    != null) fEmail    = loginUser.getEmail(); }    catch (Exception ignore) {}
        try { if (loginUser.getRole()     != null) fRole     = loginUser.getRole(); }     catch (Exception ignore) {}
        try { if (loginUser.getProfileImage() != null && !loginUser.getProfileImage().isEmpty()) fProfile = loginUser.getProfileImage(); } catch (Exception ignore) {}
    } else {
        // 하드코딩(문자열) 로그인일 때 최소 기본값
        fUsername = displayName;
        fRole     = "ADMIN";
    }

    // 프로필 이미지 기본값
    if (fProfile == null || fProfile.trim().isEmpty()) {
        fProfile = ctx + "/assets/img/profile-default.png"; // 프로젝트에 없으면 이미지 생략돼도 무방
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8" />
    <title>마이페이지</title>
    <link rel="icon" type="image/x-icon" href="<%=ctx%>/assets/favicon.ico" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=ctx%>/css/styles.css" rel="stylesheet" />
</head>

<!-- ✅ 스티키(고정 아님) 레이아웃 -->
<body class="d-flex flex-column min-vh-100">

<!-- 상단 네비 -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
  <div class="container px-5">
    <a class="navbar-brand" href="<%=ctx%>/main.jsp">볼피또</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse"
            data-bs-target="#navbarNav" aria-controls="navbarNav"
            aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarNav">
      <ul class="navbar-nav ms-auto mb-2 mb-lg-0">
        <li class="nav-item">
          <span class="nav-link disabled"><%= displayName %>님</span>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="<%=ctx%>/main.jsp">홈</a>
        </li>
        <li class="nav-item">
          <a class="nav-link active" aria-current="page" href="<%=ctx%>/mypage.jsp">마이페이지</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="<%=ctx%>/logout.jsp">로그아웃</a>
        </li>
      </ul>
    </div>
  </div>
</nav>

<!-- 본문 -->
<main class="flex-grow-1">
  <div class="container py-5 px-4 px-lg-5 pb-5"><!-- ✅ 푸터와 간격 -->
    <h1 class="mb-4 fw-bold">마이페이지</h1>

    <div class="row g-4">
      <div class="col-md-4">
        <div class="card shadow-sm">
          <div class="card-body text-center">
            <img src="<%=fProfile%>" alt="프로필 이미지" class="rounded-circle mb-3" style="width:140px;height:140px;object-fit:cover;">
            <h4 class="fw-bold"><%= fName %></h4>
            <p class="text-muted mb-0"><small>역할(Role): <%= fRole %></small></p>
          </div>
        </div>
      </div>

      <div class="col-md-8">
        <div class="card shadow-sm">
          <div class="card-body">
            <h5 class="mb-3">계정 정보</h5>
            <div class="mb-2">
              <span class="text-muted">아이디(Username)</span>
              <div class="fw-semibold"><%= fUsername %></div>
            </div>
            <div class="mb-2">
              <span class="text-muted">이름(Name)</span>
              <div class="fw-semibold"><%= fName %></div>
            </div>
            <div class="mb-2">
              <span class="text-muted">이메일(Email)</span>
              <div class="fw-semibold"><%= fEmail %></div>
            </div>
            <div class="d-flex gap-2 mt-4">
              <a href="<%=ctx%>/edit_profile.jsp" class="btn btn-primary">프로필 수정</a>
              <a href="<%=ctx%>/main.jsp" class="btn btn-outline-secondary">홈으로</a>
              <a href="<%=ctx%>/logout.jsp" class="btn btn-outline-danger ms-auto">로그아웃</a>
            </div>
          </div>
        </div>
      </div>
    </div>

  </div>
</main>

<!-- ✅ 문서 하단에만 위치하는 푸터 -->
<footer class="mt-auto py-4 bg-dark text-light">
  <div class="container px-4 px-lg-5">
    <p class="m-0 text-center">Copyright &copy; 볼피또 2025</p>
  </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="<%=ctx%>/js/scripts.js"></script>
</body>
</html>
