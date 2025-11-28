<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.BoardDAO" %>

<%
    request.setCharacterEncoding("UTF-8");

    String name = request.getParameter("name");
    String result = "ok";

    try (BoardDAO dao = new BoardDAO()) {
        dao.insert(name);  // 중복 발생 시 DAO 내부에서 throw됨
    }
    catch (Exception e) {

        // 중복판별: MySQL에서 UNIQUE 충돌 시 SQLState = 23000
        if (e instanceof java.sql.SQLException &&
            ((java.sql.SQLException)e).getSQLState().equals("23000")) {
            result = "duplicate";
        } else {
            result = "error";
        }
    }

    response.sendRedirect("board_add_result.jsp?result=" + result);
%>
