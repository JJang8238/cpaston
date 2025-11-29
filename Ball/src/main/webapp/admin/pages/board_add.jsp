<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    String ctx = request.getContextPath();
%>

<!-- Bootstrap CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
    .center-wrapper {
        max-width: 600px;
        margin: 50px auto;
    }
</style>

<div class="center-wrapper">

    <div class="card shadow-sm">
        <div class="card-body">

            <h3 class="fw-bold mb-4 text-center">게시판 추가</h3>

            <form method="post" action="board_add_action.jsp">

                <div class="mb-3">
                    <label class="form-label">게시판 이름</label>
                    <input type="text"
                           name="name"
                           class="form-control"
                           placeholder="예: 자유게시판 / 게임 / 맛집"
                           required>
                </div>

                <div class="d-flex gap-2">
                    <button type="submit" class="btn btn-primary">추가하기</button>
                    <a href="<%=ctx%>/admin/admin_menu.jsp?page=board"
                       class="btn btn-secondary">취소</a>
                </div>

            </form>

        </div>
    </div>

</div>
