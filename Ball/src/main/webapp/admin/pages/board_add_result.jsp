<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    request.setCharacterEncoding("UTF-8");
    String result = request.getParameter("result");
    String ctx = request.getContextPath();

    String msg = "";

    if ("duplicate".equals(result)) {
        msg = "이미 존재하는 게시판입니다.";
    } else if ("error".equals(result)) {
        msg = "게시판 추가 중 오류가 발생했습니다.";
    } else {
        msg = "게시판이 성공적으로 추가되었습니다.";
    }
%>

<script>
    alert("<%= msg %>");
    location.href = "<%= ctx %>/admin/admin_menu.jsp?page=board";
</script>
