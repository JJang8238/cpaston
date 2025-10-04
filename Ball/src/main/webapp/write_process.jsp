<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
  request.setCharacterEncoding("UTF-8");

  String category = request.getParameter("category");
  String title    = request.getParameter("title");
  String content  = request.getParameter("content"); // 추후 상세에서 사용

  if (category == null) category = "전체";
  List<String> allowed = Arrays.asList("전체","인기글","동네질문");
  if (!allowed.contains(category)) category = "전체";
  if (title == null) title = "";
  title = title.trim();

  // application 스코프 저장 (임시)
  Map<String, List<String>> POSTS = (Map<String, List<String>>) application.getAttribute("POSTS");
  if (POSTS == null) {
      POSTS = new LinkedHashMap<String, List<String>>();
      for (String k : allowed) POSTS.put(k, new ArrayList<String>());
      application.setAttribute("POSTS", POSTS);
  }

  if (!title.isEmpty()) {
      synchronized (POSTS) {
          List<String> list = POSTS.get(category);
          if (list == null) { list = new ArrayList<String>(); POSTS.put(category, list); }
          list.add(title);
      }
  }

  // 목록으로 리다이렉트
  String ctx = request.getContextPath();
  response.sendRedirect(ctx + "/community.jsp?category=" +
                        java.net.URLEncoder.encode(category, "UTF-8"));
%>
