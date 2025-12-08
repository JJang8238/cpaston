<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.BoardDAO" %>

<%
    request.setCharacterEncoding("UTF-8");

    int id = Integer.parseInt(request.getParameter("id"));
    String name = request.getParameter("name");

    int result = 0;

    try (BoardDAO dao = new BoardDAO()) {

        // 고정 게시판 수정 불가
        if (dao.isFixedBoard(id)) {
%>
            <script>
                alert("고정 게시판은 수정할 수 없습니다.");
                history.back();
            </script>
<%
            return;
        }

        result = dao.updateBoardName(id, name);
    }

    if (result > 0) {
%>
        <script>
            alert("게시판이 수정되었습니다.");
            location.href = "<%=request.getContextPath()%>/admin/admin_menu.jsp?page=board";
        </script>
<%
    } else {
%>
        <script>
            alert("수정 실패! 다시 시도해주세요.");
            history.back();
        </script>
<%
    }
%>
