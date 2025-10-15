<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>

<%
    // 컨텍스트 루트 (다른 JSP에서 ctx를 쓰는 경우가 있어 충돌 피하려고 ctxPath 사용)
    String ctxPath = request.getContextPath();

    // 세션 속성
    Object loginUser = session.getAttribute("loginUser"); // DTO(User)일 가능성
    Object userIdObj = session.getAttribute("userId");    // 숫자/문자 가능
    String username  = (String) session.getAttribute("username");
    String name      = (String) session.getAttribute("name");

    // 로그인 여부
    boolean loggedIn = (loginUser != null) || (userIdObj != null) || (username != null) || (name != null);

    // 표시 이름 결정: name → username → loginUser.getName/getUsername → (옵션) userId → 기본 "회원"
    String displayName = null;
    if (name != null && !name.isEmpty()) {
        displayName = name;
    } else if (username != null && !username.isEmpty()) {
        displayName = username;
    } else if (loginUser != null) {
        try {
            java.lang.reflect.Method m = null;
            try { m = loginUser.getClass().getMethod("getName"); } catch (Exception ignore) {}
            if (m == null) { try { m = loginUser.getClass().getMethod("getUsername"); } catch (Exception ignore) {} }
            if (m != null) {
                Object v = m.invoke(loginUser);
                if (v != null && !v.toString().isEmpty()) displayName = v.toString();
            }
        } catch (Exception ignore) {}
    }
    // userId를 이름으로 노출하고 싶지 않다면 주석 유지
    // else if (userIdObj != null) { displayName = String.valueOf(userIdObj); }

    if (displayName == null) displayName = "회원";
%>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">

<nav class="navbar navbar-expand-lg navbar-dark" style="background:#212529">
  <div class="container">
    <a class="navbar-brand fw-bold" href="<%=ctxPath%>/main.jsp">플랩풋볼</a>

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

          <li class="nav-item"><a class="nav-link" href="<%=ctxPath%>/main.jsp">홈</a></li>
          <li class="nav-item"><a class="nav-link" href="<%=ctxPath%>/mypage.jsp">마이페이지</a></li>
          <!-- 로그아웃 경로는 프로젝트에 맞게 조정하세요 -->
          <li class="nav-item"><a class="nav-link" href="<%=ctxPath%>/logout.jsp">로그아웃</a></li>
        <% } else { %>
          <li class="nav-item"><a class="nav-link" href="<%=ctxPath%>/main.jsp">Home</a></li>
          <li class="nav-item"><a class="nav-link" href="<%=ctxPath%>/login.jsp">로그인</a></li>
          <li class="nav-item"><a class="nav-link" href="<%=ctxPath%>/register.jsp">회원가입</a></li>

        <% } %>
      </ul>
    </div>
  </div>

</nav>

