<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true"%>
<%@ page import="java.util.List" %>
<%@ page import="dao.UserDAO" %>
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
    .layout {
        display: flex;
        min-height: 100vh;
    }
    .sidebar {
        width: 220px;
        background: #343a40;
        padding: 20px;
        color: white;
    }
    .sidebar a {
        display: block;
        color: #ddd;
        padding: 10px 0;
        text-decoration: none;
        margin: 5px 0;
    }
    .sidebar a:hover {
        color: white;
    }
    .content {
        flex: 1;
        padding: 30px;
        background: #f8f9fa;
    }
</style>

</head>
<body>

<!-- 상단바 -->
<nav class="navbar navbar-dark bg-dark px-4">
    <span class="navbar-brand">관리자 페이지</span>

    <div>
        <a href="<%=ctx%>/admin/admin_main.jsp" class="btn btn-outline-light btn-sm me-3">
            홈
        </a>
        <span class="text-white"><%=loginUser.getName()%> 관리자님</span>
    </div>
</nav>

<div class="layout">
    <div class="sidebar">
        <a href="<%=ctx%>/admin/admin_menu.jsp?page=user">회원 관리</a>
        <a href="<%=ctx%>/admin/admin_menu.jsp?page=match">경기 관리</a>

        <!-- 리뷰 관리 → 서블릿 호출 -->
        <a href="<%=ctx%>/admin/place-review">리뷰 관리</a>

        <a href="<%=ctx%>/admin/admin_menu.jsp?page=report">신고 처리</a>

        <a href="<%=ctx%>/admin/admin_menu.jsp?page=stats">커뮤니티 관리</a>

        <hr>
        <a href="<%=ctx%>/admin/admin_main.jsp">사용자 홈</a>
        <a href="<%=ctx%>/logout.jsp">로그아웃</a>
    </div>

    <div class="content">

        <% if (pageParam == null) { %>

            <h3>관리자 메인</h3>
            <p>왼쪽 메뉴에서 원하는 기능을 선택하세요.</p>

        <% } else if ("user".equals(pageParam)) { %>

            <jsp:include page="pages/user_manage.jsp" />

        <% } else if ("match".equals(pageParam)) { %>

            <jsp:include page="pages/match_manage.jsp" />

        <% } else if ("review".equals(pageParam)) { %>

            <!-- 리뷰 관리 -->
            <jsp:include page="pages/review_manage.jsp" />

        <% } else if ("report".equals(pageParam)) { %>

            <jsp:include page="pages/report_manage.jsp" />


        <% } else { %>

            <p>잘못된 페이지입니다.</p>

        <% } %>

    </div>
</div>

</body>
</html>
