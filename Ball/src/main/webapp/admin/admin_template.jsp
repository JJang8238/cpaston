<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="dto.User" %>

<%
    // 로그인 체크
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
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>관리자 페이지</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .admin-layout {
            display: flex;
            min-height: 100vh;
        }
        .sidebar {
            width: 220px;
            background: #343a40;
            color: white;
            padding: 20px;
        }
        .sidebar a {
            color: #ddd;
            text-decoration: none;
            display: block;
            margin: 10px 0;
        }
        .sidebar a:hover {
            color: white;
        }
        .content {
            flex: 1;
            padding: 30px;
        }
    </style>
</head>

<body>

<div class="admin-layout">

    <!-- 사이드바 -->
    <div class="sidebar">
        <h4>관리자 메뉴</h4>
        <a href="<%=ctx%>/ADMIN/user_manage.jsp">회원 관리</a>
        <a href="<%=ctx%>/ADMIN/match_manage.jsp">경기 관리</a>
        <a href="<%=ctx%>/ADMIN/review_manage.jsp">리뷰 관리</a>
        <a href="<%=ctx%>/ADMIN/report_manage.jsp">신고 관리</a>
        <a href="<%=ctx%>/ADMIN/statistics.jsp">통계</a>
        <hr>
        <a href="<%=ctx%>/ADMIN/admin_main.jsp">관리자 메인</a>
        <a href="<%=ctx%>/main.jsp">사용자 홈</a>
        <a href="<%=ctx%>/logout.jsp">로그아웃</a>
    </div>

    <!-- 콘텐츠 영역 -->
    <div class="content">
        <!-- 여기에 각 관리자 기능 페이지 내용이 들어감 -->
        <%-- EX: 사용자 관리 테이블, 경기 리스트 등이 여기에 표시됨 --%>
