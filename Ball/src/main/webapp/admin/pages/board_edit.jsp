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
        fixed = dao.isFixedBoard(id);  // 🔥 고정 여부 체크
        board = dao.get(id);
    }

    // 🔥 고정 게시판 수정 방지
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
    .center-wrapper {
        max-width: 600px;
        margin: 50px auto;
    }
</style>

<div class="center-wrapper">

    <div class="card shadow-sm">
        <div class="card-body">

            <h3 class="fw-bold mb-4 text-center">게시판 수정</h3>

            <form method="post" action="board_edit_process.jsp">

                <input type="hidden" name="id" value="<%=board.getId()%>">

                <div class="mb-3">
                    <label class="form-label">게시판 이름</label>
                    <input type="text"
                           name="name"
                           class="form-control"
                           value="<%=board.getName()%>"
                           required>
                </div>

                <div class="d-flex gap-2">
                    <button type="submit" class="btn btn-primary">수정하기</button>
                    <a href="<%=ctx%>/admin/admin_menu.jsp?page=board"
                       class="btn btn-secondary">취소</a>
                </div>

            </form>

        </div>
    </div>

</div>
