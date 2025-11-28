<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.BoardDAO" %>

<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    int id = Integer.parseInt(request.getParameter("id"));

    String msg = null;

    try (BoardDAO dao = new BoardDAO()) {
        dao.delete(id);
        msg = "게시판이 삭제되었습니다.";
    } catch (IllegalStateException e) {
        // 전체 게시판 삭제 시도 등
        msg = e.getMessage(); 
    } catch (Exception e) {
        msg = "게시판 삭제 중 오류가 발생했습니다.";
    }
%>

<script>
    alert("<%= msg %>");
    location.href = "<%= ctx %>/admin/admin_menu.jsp?page=board";
</script>