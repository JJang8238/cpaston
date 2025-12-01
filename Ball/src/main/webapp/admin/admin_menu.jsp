<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true"%>
<%@ page import="dto.User" %>

<%
    // 로그인 / 권한 체크
    Object obj = session.getAttribute("loginUser");
    if (obj == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }

    User loginUser = (User) obj;
    if (!"admin".equalsIgnoreCase(loginUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }

    String ctx = request.getContextPath();
    String pageParam = request.getParameter("page");
%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>관리자 페이지</title>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">

<style>

/* ====== 전체 레이아웃 ====== */
body {
    background: #f1f3f5;
}

.layout {
    display: flex;
    min-height: calc(100vh - 56px);
}

/* ===== 사이드바 ===== */
.sidebar {
    width: 230px;
    background: #212529;
    padding: 25px 20px;
    color: white;
    box-shadow: 2px 0 8px rgba(0,0,0,0.15);
}

.sidebar-title {
    font-size: 18px;
    font-weight: bold;
    margin-bottom: 15px;
}

.sidebar a {
    display: flex;
    align-items: center;
    gap: 8px;
    color: #ced4da;
    padding: 10px 12px;
    border-radius: 6px;
    font-size: 15px;
    text-decoration: none;
    margin-bottom: 5px;
    transition: 0.15s;
}

.sidebar a:hover {
    background: #343a40;
    color: #fff;
}

/* ===== 콘텐츠 영역 ===== */
.content {
    flex: 1;
    padding: 35px;
    background: #f8f9fa;
}

/* 콘텐츠 박스 */
.content-box {
    background: white;
    padding: 25px;
    border-radius: 10px;
    border: 1px solid #dee2e6;
    box-shadow: 0 2px 6px rgba(0,0,0,0.05);
}

</style>
</head>

<body>

<!-- 상단바 -->
<nav class="navbar navbar-dark bg-dark px-4">
    <span class="navbar-brand fw-bold">관리자 페이지</span>

    <div>
        <a href="<%=ctx%>/admin/admin_main.jsp" class="btn btn-outline-light btn-sm me-3">홈</a>
        <span class="text-white fw-bold"><%=loginUser.getName()%> 관리자님</span>
    </div>
</nav>

<div class="layout">

    <!-- ▣ 사이드바 -->
    <div class="sidebar">
        <div class="sidebar-title">관리 메뉴</div>

        <a href="<%=ctx%>/admin/admin_menu.jsp?page=user">👤 회원 관리</a>
        <a href="<%=ctx%>/admin/admin_menu.jsp?page=match">⚽ 경기 관리</a>
        <a href="<%=ctx%>/admin/place-review">⭐ 리뷰 관리</a>
        <a href="<%=ctx%>/admin/admin_menu.jsp?page=report">🚨 신고 처리</a>
        <a href="<%=ctx%>/admin/admin_menu.jsp?page=board">📝 커뮤니티 관리</a>

        <hr style="border-color:#495057;">
        <a href="<%=ctx%>/main.jsp">🏠 사용자 홈</a>
        <a href="<%=ctx%>/logout.jsp">🔓 로그아웃</a>
    </div>

    <!-- ▣ 콘텐츠 영역 -->
    <div class="content">

        <div class="content-box">
        <% if (pageParam == null) { %>

            <h3 class="fw-bold">관리자 메인</h3>
            <p>왼쪽 메뉴에서 원하는 기능을 선택하세요.</p>

        <% } else if ("user".equals(pageParam)) { %>

            <jsp:include page="pages/user_manage.jsp"/>

        <% } else if ("match".equals(pageParam)) { %>

            <jsp:include page="pages/match_manage.jsp"/>

        <% } else if ("review".equals(pageParam)) { %>

            <jsp:include page="pages/review_manage.jsp"/>

        <% } else if ("report".equals(pageParam)) { %>

            <jsp:include page="pages/report_manage.jsp"/>

        <% } else if ("board".equals(pageParam)) { %>

            <jsp:include page="pages/board_manage.jsp"/>

        <% } else { %>

            <p>잘못된 페이지입니다.</p>

        <% } %>
        </div>

    </div>

</div>

</body>
</html>
