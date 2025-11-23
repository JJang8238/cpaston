<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>경기 생성</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>

<body class="bg-light">

<div class="container my-5" style="max-width:600px;">
    <h3 class="mb-4 fw-bold">➕ 경기 생성</h3>

    <!-- ⭐ matchController 로 전송 -->
    <form action="<%=ctx%>/matchController" method="post">

        <input type="hidden" name="action" value="create">

        <label class="fw-bold">장소</label>
        <input type="text" name="place" class="form-control mb-3" required>

        <label class="fw-bold">날짜</label>
        <input type="date" name="date" class="form-control mb-3" required>

        <label class="fw-bold">시간</label>
        <input type="time" name="time" class="form-control mb-3" required>

        <label class="fw-bold">정원</label>
        <input type="number" name="max" class="form-control mb-4" required>

        <button class="btn btn-primary w-100">생성</button>
    </form>

    <button class="btn btn-secondary w-100 mt-2"
        onclick="location.href='<%=ctx%>/admin/admin_menu.jsp?page=match'">
        돌아가기
    </button>
</div>

</body>
</html>
