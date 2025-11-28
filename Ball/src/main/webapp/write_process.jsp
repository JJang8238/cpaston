<%@ page language="java" 
         contentType="text/html; charset=UTF-8" 
         pageEncoding="UTF-8" %>

<%@ page import="dao.PostDAO, dto.Post" %>
<%@ page import="dto.User" %>

<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    // 🔸 값 받기
    String title   = request.getParameter("title");
    String content = request.getParameter("content");
    String author  = request.getParameter("author");
    String boardIdParam = request.getParameter("board_id");

    if (title == null)   title = "";
    if (content == null) content = "";

    title = title.trim();
    content = content.trim();

    // 🔸 board_id 정수 변환
    int boardId = 1;
    try {
        boardId = Integer.parseInt(boardIdParam);
    } catch(Exception ignore) {}

    // 🔸 로그인 검증
    if (author == null || author.isBlank()) {
        User u = (User) session.getAttribute("loginUser");
        if (u != null) author = u.getUsername();
    }
    if (author == null || author.isBlank()) author = "guest";

    // 🔸 서버 검증
    if (title.isEmpty() || content.isEmpty()) {
        out.println("<script>alert('제목/내용을 입력하세요.'); history.back();</script>");
        return;
    }

    // 🔸 INSERT
    int newId = -1;
    try (PostDAO dao = new PostDAO()) {
        Post p = new Post();
        p.setTitle(title);
        p.setContent(content);
        p.setAuthor(author);
        p.setBoardId(boardId);  // ★ boardId 저장

        newId = dao.insert(p);
    } catch (Exception e) {
        e.printStackTrace();
    }

    // 🔸 결과 처리
    if (newId > 0) {
        // 성공 → 해당 게시판으로 이동
    	response.sendRedirect(ctx + "/community.jsp?board_id=" + boardId);
    } else {
        out.println("<script>alert('저장 실패'); history.back();</script>");
    }
%>
