<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.BoardDAO, dto.Board" %>

<!-- Bootstrap CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    int id = Integer.parseInt(request.getParameter("id"));

    Board board = null;
    boolean fixed = false;

    try (BoardDAO dao = new BoardDAO()) {
        fixed = dao.isFixedBoard(id);
        board = dao.get(id);
    }

    if (fixed) {
%>
<script>
    alert("고정 게시판은 이름을 변경할 수 없습니다.");
    history.back();
</script>
<%
        return;
    }

    if (board == null) {
%>
<script>
    alert("존재하지 않는 게시판입니다.");
    history.back();
</script>
<%
        return;
    }
%>

<style>
    body {
        background-color: #f4f6f9;
        font-family: 'Pretendard', 'Noto Sans KR', sans-serif;
    }

    .edit-container {
        max-width: 720px;
        margin: 60px auto;
    }

    .edit-card {
        background: #fff;
        border-radius: 16px;
        padding: 40px 50px;
        box-shadow: 0 4px 16px rgba(0,0,0,0.06);
    }

    .edit-title {
        font-size: 32px;
        font-weight: 700;
        text-align: center;
        margin-bottom: 35px;
    }

    .form-label {
        font-weight: 600;
        margin-bottom: 8px;
        color: #444;
    }

    .form-control {
        border-radius: 12px;
        padding: 12px 14px;
        font-size: 15px;
    }

    .btn-submit {
        background-color: #007bff;
        padding: 12px 18px;
        font-size: 16px;
        border-radius: 10px;
        width: 120px;
    }

    .btn-cancel {
        background-color: #6c757d;
        color: white;
        padding: 12px 18px;
        font-size: 16px;
        border-radius: 10px;
        width: 120px;
    }

    .btn-wrapper {
        margin-top: 35px;
        display: flex;
        justify-content: center;
        gap: 15px;
    }
</style>

<div class="edit-container">
    <div class="edit-card">

        <h2 class="edit-title">게시판 수정</h2>

        <form method="post" action="<%=ctx%>/admin/pages/board_edit_process.jsp">

            <input type="hidden" name="id" value="<%=board.getId()%>">

            <div class="mb-3">
                <label class="form-label">게시판 이름</label>
                <input type="text"
                       name="name"
                       class="form-control"
                       value="<%=board.getName()%>"
                       required>
            </div>

            <div class="btn-wrapper">
                <button type="submit" class="btn btn-primary btn-submit">수정하기</button>

                <a href="<%=ctx%>/admin/admin_menu.jsp?page=board"
                   class="btn btn-cancel">취소</a>
            </div>

        </form>

    </div>
</div>
