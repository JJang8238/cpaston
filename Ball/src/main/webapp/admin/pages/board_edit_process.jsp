<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.BoardDAO" %>

<%
    request.setCharacterEncoding("UTF-8");

    int id = Integer.parseInt(request.getParameter("id"));
    String name = request.getParameter("name");

    try (BoardDAO dao = new BoardDAO()) {
        // 🔥 수정 처리
        dao.update(id, name);
    }

    // 🔥 수정 완료 후 목록으로 이동
    response.sendRedirect(request.getContextPath() + "/admin/admin_menu.jsp?page=board");
%>
