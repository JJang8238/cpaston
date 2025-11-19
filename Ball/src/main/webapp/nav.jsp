<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dto.User" %>

<%
    // 현재 요청 URL 가져오기
    String uri = request.getRequestURI();

    // AJAX API 요청은 로그인 체크 제외
    boolean isApiRequest =
            uri.contains("/review") ||       // 리뷰 API
            uri.contains("/reserve") ||      // 경기 예약/조회 API
            uri.contains("/assets") ||       // 이미지/JS/CSS는 무조건 통과
            uri.contains("/kakao");          // 카카오맵 스크립트

    if (!isApiRequest) {
        // 로그인 여부 확인
        User user = (User) session.getAttribute("loginUser");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }
    }

    // 네비게이션 표시용 로그인 정보
    User loginUser = (User) session.getAttribute("loginUser");
    String username = (loginUser != null ? loginUser.getUsername() : "");
%>

<!-- 🔥 네비게이션 바 -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container px-5">
        <a class="navbar-brand" href="<%=request.getContextPath()%>/main.jsp">볼피또</a>

        <button class="navbar-toggler" type="button" data-bs-toggle="collapse"
                data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent"
                aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbarSupportedContent">
            <ul class="navbar-nav ms-auto mb-2 mb-lg-0">

                <% if (loginUser != null) { %>
                    <li class="nav-item">
                        <span class="nav-link disabled"><%=username%>님 환영합니다</span>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="<%=request.getContextPath()%>/main.jsp">홈</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="<%=request.getContextPath()%>/mypage.jsp">마이페이지</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="<%=request.getContextPath()%>/logout.jsp">로그아웃</a>
                    </li>
                <% } else { %>
                    <!-- 로그인 안 된 사용자 메뉴(필요 시 추가 가능) -->
                    <li class="nav-item">
                        <a class="nav-link" href="<%=request.getContextPath()%>/index.jsp">로그인</a>
                    </li>
                <% } %>

            </ul>
        </div>
    </div>
</nav>
