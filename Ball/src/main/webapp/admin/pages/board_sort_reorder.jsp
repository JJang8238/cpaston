<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.BoardDAO" %>

<%
    request.setCharacterEncoding("UTF-8");
    String[] order = request.getParameterValues("order");

    if (order == null) {
        out.print("error");
        return;
    }

    try (BoardDAO dao = new BoardDAO()) {

        // 고정 게시판 이동 금지 로직 수행
        dao.updateSortOrder(order);

        out.print("ok");

    } catch (IllegalStateException e) {
        // 고정 게시판 이동 시도
        out.print("error");
    } catch (Exception e) {
        out.print("error");
    }
%>