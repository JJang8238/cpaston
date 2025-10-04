<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="dto.User" %>
<%
    // 세션에서 로그인 유저 정보 조회 (여러 키를 허용)
    User loginUser = (User) session.getAttribute("loginUser");
    Object userId   = session.getAttribute("userId");
    String username = (String) session.getAttribute("username");

    boolean loggedIn = (loginUser != null) || (userId != null) || (username != null);

    // 표시 이름 결정
    String displayName = null;
    if (loginUser != null) {
        try {
            // dto.User에 getName() 또는 getUsername() 중 있는 것 사용
            java.lang.reflect.Method m = null;
            try { m = loginUser.getClass().getMethod("getName"); } catch (Exception ignore) {}
            if (m == null) { try { m = loginUser.getClass().getMethod("getUsername"); } catch (Exception ignore) {} }
            if (m != null) displayName = String.valueOf(m.invoke(loginUser));
        } catch (Exception ignore) {}
    }
    if (displayName == null) {
        displayName = (username != null) ? username : "회원";
    }

    String ctx = request.getContextPath(); // /Ball 같은 컨텍스트 루트
%>
<!-- 상단 네비게이션 바 -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
<nav class="navbar navbar-expand-lg navbar-dark" style="background:#212529">
  <div class="container">
    <a class="navbar-brand fw-bold" href="<%=ctx%>/main.jsp">플랩풋볼</a>

    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#topNav"
            aria-controls="topNav" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse justify-content-end" id="topNav">
      <ul class="navbar-nav align-items-lg-center gap-lg-3">
        <% if (loggedIn) { %>
          <li class="nav-item">
            <span class="navbar-text text-secondary me-lg-2"><%=displayName%>님 환영합니다</span>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="<%=ctx%>/main.jsp">홈</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="<%=ctx%>/mypage.jsp">마이페이지</a>
          </li>
          <li class="nav-item">
            <!-- 로그아웃 경로는 프로젝트에 맞게 조정 -->
            <a class="nav-link" href="<%=ctx%>/logout.jsp">로그아웃</a>
          </li>
        <% } else { %>
          <li class="nav-item">
            <a class="nav-link" href="<%=ctx%>/main.jsp">Home</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="<%=ctx%>/login.jsp">로그인</a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="<%=ctx%>/register.jsp">회원가입</a>
          </li>
        <% } %>
      </ul>
    </div>
  </div>
</nav>
