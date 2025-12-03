<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="dao.BoardDAO, dto.Board" %>

<%
    String ctx = request.getContextPath();
    List<Board> boards = new ArrayList<>();

    int allId = -1;
    int hotId = -1;

    try (BoardDAO dao = new BoardDAO()) {
        boards = dao.list();
        allId = dao.getAllBoardId();
        hotId = dao.getHotBoardId();
    }
%>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://code.jquery.com/ui/1.13.3/jquery-ui.min.js"></script>
<link rel="stylesheet" href="https://code.jquery.com/ui/1.13.3/themes/base/jquery-ui.css">

<style>
    .drag-handle {
        cursor: move;
        font-size: 20px;
        padding: 3px;
    }
    .fixed-board {
        background-color: #f1f1f1;
        color: #555;
    }
</style>

<h2 class="fw-bold mb-4">게시판 관리</h2>

<div class="mb-3 text-end">
    <a href="<%=ctx%>/admin/pages/board_add.jsp" class="btn btn-primary">게시판 추가</a>
</div>

<table class="table table-bordered table-hover bg-white shadow-sm">
    <thead class="table-dark">
        <tr>
            <th width="40">#</th>
            <th>게시판 이름</th>
            <th width="150">관리</th>
        </tr>
    </thead>

    <tbody id="sortableBody">

    <% for (Board b : boards) { 
        boolean fixed = (b.getId() == allId || b.getId() == hotId);
    %>
        <tr class="<%= fixed ? "fixed-board" : "sortable-row" %>" 
            data-id="<%=b.getId()%>">

            <!-- 드래그 핸들: 고정 게시판은 비활성화 -->
            <td class="text-center">
                <% if (fixed) { %>
                    <span style="color:#aaa;">✖</span>
                <% } else { %>
                    <span class="drag-handle">≡</span>
                <% } %>
            </td>

            <td>
                <%= b.getName() %>
                <% if (fixed) { %>
                    <span style="color:#888; font-size:12px;">(고정)</span>
                <% } %>
            </td>

            <td>
                <% if (!fixed) { %>
                    <a href="<%=ctx%>/admin/pages/board_edit.jsp?id=<%=b.getId()%>" 
                       class="btn btn-warning btn-sm">수정</a>

                    <a href="<%=ctx%>/admin/pages/board_delete.jsp?id=<%=b.getId()%>"
                       onclick="return confirm('삭제하시겠습니까?');"
                       class="btn btn-danger btn-sm">삭제</a>
                <% } else { %>
                    <button class="btn btn-secondary btn-sm" disabled>수정 불가</button>
                <% } %>
            </td>
        </tr>
    <% } %>

    </tbody>
</table>


<script>
// 드래그 정렬 기능
$("#sortableBody").sortable({
    handle: ".drag-handle",
    cancel: ".fixed-board", // 🔥 고정 게시판 드래그 불가
    placeholder: "ui-state-highlight",

    update: function(event, ui) {
        let order = [];

        $("#sortableBody tr").each(function() {
            order.push($(this).data("id"));
        });

        $.ajax({
            url: "<%=ctx%>/admin/pages/board_sort_reorder.jsp",
            type: "POST",
            traditional: true,
            data: { order: order },

            success: function(res) {
                if (res.trim() === "error") {
                    alert("고정 게시판은 순서를 변경할 수 없습니다.");
                }
            }
        });
    }
});
</script>