<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.BoardDAO" %>

<%
    request.setCharacterEncoding("UTF-8");

    String name = request.getParameter("name");
    String result = "ok";   // 기본값

    try (BoardDAO dao = new BoardDAO()) {
        dao.insert(name);
    } 
    catch (java.sql.SQLIntegrityConstraintViolationException e) {
        result = "duplicate";    // 이미 존재하는 게시판 이름
    }
    catch (Exception e) {
        result = "error";        // 기타 오류
    }

    // 결과만 result 파라미터로 넘기기
    response.sendRedirect("board_add_result.jsp?result=" + result);
%>
