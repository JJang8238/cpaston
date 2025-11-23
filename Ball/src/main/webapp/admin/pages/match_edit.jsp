<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.MatchDAO, dto.Match" %>

<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    // 파라미터 확인
    String idParam = request.getParameter("id");
    if (idParam == null) {
        out.println("<h3>잘못된 접근입니다.</h3>");
        return;
    }

    int matchId = Integer.parseInt(idParam);

    MatchDAO dao = new MatchDAO();
    Match m = dao.getMatchById(matchId);  // ★ 새로운 메소드로 변경
    if (m == null) {
        out.println("<h3>경기 정보를 찾을 수 없습니다.</h3>");
        return;
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>경기 수정</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body {
            background: #f8f9fa;
        }
        .admin-layout {
            display: flex;
        }

        /* 왼쪽 관리자 메뉴 */
        .sidebar {
            width: 240px;
            height: 100vh;
            background: #212529;
            color: white;
            padding: 20px;
            position: fixed;
            top: 0;
            left: 0;
        }

        .sidebar h3 {
            font-size: 22px;
            margin-bottom: 30px;
        }

        .sidebar a {
            display: block;
            padding: 12px;
            margin-bottom: 8px;
            background: #343a40;
            color: #fff;
            text-decoration: none;
            border-radius: 5px;
        }

        .sidebar a:hover {
            background: #495057;
        }

        /* 오른쪽 본문 */
        .main-content {
            margin-left: 260px;
            padding: 40px;
            width: calc(100% - 260px);
        }

        .form-box {
            max-width: 600px;
            margin: auto;
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }

    </style>
</head>
<body>

<div class="admin-layout">

    <!-- 왼쪽 관리자 메뉴 -->
    <div class="sidebar">
        <h3>관리자 페이지</h3>

        <a href="<%= ctx %>/admin/admin_menu.jsp?page=member">회원 관리</a>
        <a href="<%= ctx %>/admin/admin_menu.jsp?page=match">경기 관리</a>
        <a href="<%= ctx %>/admin/admin_menu.jsp?page=review">리뷰 관리</a>
        <a href="<%= ctx %>/admin/admin_menu.jsp?page=report">신고 처리</a>
        <a href="<%= ctx %>/admin/admin_menu.jsp?page=community">커뮤니티 관리</a>

        <hr style="background:#666;">

        <a href="<%= ctx %>/main.jsp">사용자 홈</a>
        <a href="<%= ctx %>/logout">로그아웃</a>
    </div>

    <!-- 오른쪽 본문 -->
    <div class="main-content">

        <h2 class="mb-4 fw-bold">⚽ 경기 수정</h2>

        <div class="form-box">
            <form action="<%= ctx %>/matchController?action=update" method="post">

                <input type="hidden" name="id" value="<%= m.getId() %>">

                <!-- 장소 -->
                <label class="mt-2">장소</label>
                <input type="text" name="place" class="form-control"
                       value="<%= m.getLocation() %>" required>

                <!-- 날짜 -->
                <label class="mt-3">날짜</label>
                <input type="date" name="date" class="form-control"
                       value="<%= m.getMatchDate() %>" required>

                <!-- 시간 -->
                <label class="mt-3">시간</label>
                <input type="time" name="time" class="form-control"
                       value="<%= m.getMatchTime() %>" required>

                <!-- 정원 -->
                <label class="mt-3">정원</label>
                <input type="number" name="max" class="form-control"
                       value="<%= m.getMaxPlayers() %>" required>

                <button class="btn btn-primary w-100 mt-4">수정 완료</button>
            </form>

            <a href="<%= ctx %>/admin/admin_menu.jsp?page=match"
               class="btn btn-secondary w-100 mt-3">취소</a>
        </div>

    </div>
</div>

</body>
</html>
