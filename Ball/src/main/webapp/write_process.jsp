<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.PostDAO, dto.Post" %>
<%@ page import="dto.User" %>
<%@ page import="java.net.URLEncoder" %>
<%
  request.setCharacterEncoding("UTF-8");
  String ctx = request.getContextPath();

  String title    = request.getParameter("title");
  String content  = request.getParameter("content");
  String category = request.getParameter("category");
  String author   = request.getParameter("author"); // write.jsp에서 hidden 전달

  if (category == null || category.trim().isEmpty()) category = "전체";
  if (title == null)   title   = "";
  if (content == null) content = "";
  title = title.trim(); content = content.trim();

  // author 없으면 세션에서 보강
  if (author == null || author.trim().isEmpty()) {
    Object obj = session.getAttribute("loginUser");
    if (obj instanceof dto.User) {
      try {
        author = ((User)obj).getUsername();
        if (author == null || author.isEmpty()) author = ((User)obj).getName();
      } catch (Exception ignore) {}
    } else if (obj != null) {
      author = String.valueOf(obj);
    }
    if (author == null || author.trim().isEmpty()) author = "guest";
  }

  // 서버 검증
  if (title.isEmpty() || content.isEmpty()) {
    out.println("<script>alert('제목과 내용을 입력해 주세요.'); history.back();</script>");
    return;
  }

  int newId = -1;
  try (PostDAO dao = new PostDAO()) {
    Post p = new Post();
    p.setTitle(title);
    p.setContent(content);
    p.setCategory(category);
    p.setAuthor(author);
    newId = dao.insert(p);
  } catch (Exception e) { e.printStackTrace(); }

  if (newId > 0) {
    // ✅ 저장 성공 → 목록으로 리다이렉트
    response.sendRedirect(ctx + "/community.jsp?category=" + URLEncoder.encode(category, "UTF-8"));
  } else {
    out.println("<script>alert('저장에 실패했습니다.'); history.back();</script>");
  }
%>
