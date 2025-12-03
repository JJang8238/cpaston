<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="dto.User" %>

<%
    String ctxPath = request.getContextPath();

    // 로그인 객체 (이것만 쓰면 충분)
    User loginUser = (User) session.getAttribute("loginUser");

    boolean loggedIn = (loginUser != null);

    // 표시용 이름
    String displayName = "회원";
    if (loggedIn) {
        if (loginUser.getName() != null && !loginUser.getName().isEmpty()) {
            displayName = loginUser.getName();
        } else if (loginUser.getUsername() != null) {
            displayName = loginUser.getUsername();
        }
    }
%>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">

<nav class="navbar navbar-expand-lg navbar-dark" style="background:#212529">
  <div class="container">
    <a class="navbar-brand fw-bold" href="<%=ctxPath%>/main.jsp">볼삐또</a>

    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#topNav">
      <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse justify-content-end" id="topNav">
      <ul class="navbar-nav align-items-lg-center gap-lg-3">
        <% if (loggedIn) { %>
          <li class="nav-item">
            <span class="navbar-text text-secondary me-lg-2"><%=displayName%>님 환영합니다</span>
          </li>
          <li class="nav-item"><a class="nav-link" href="<%=ctxPath%>/main.jsp">홈</a></li>
          <li class="nav-item"><a class="nav-link" href="<%=ctxPath%>/mypage.jsp">마이페이지</a></li>
          <li class="nav-item"><a class="nav-link" href="<%=ctxPath%>/logout.jsp">로그아웃</a></li>
        <% } else { %>
          <li class="nav-item"><a class="nav-link" href="<%=ctxPath%>/login.jsp">로그인</a></li>
          <li class="nav-item"><a class="nav-link" href="<%=ctxPath%>/register.jsp">회원가입</a></li>
        <% } %>
      </ul>
    </div>
  </div>
</nav>

<main class="container mt-4">