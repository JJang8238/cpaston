<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dto.User" %>
<%
    // 로그인 / 권한 체크
    Object obj = session.getAttribute("loginUser");
    if (obj == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }

    User loginUser = (User) obj;
    if (!"admin".equalsIgnoreCase(loginUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }

    String ctx = request.getContextPath();
    String pageParam = request.getParameter("page");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>공지 작성</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
      body { background:#f8f9fa; }
    </style>
</head>
<body class="d-flex flex-column min-vh-100">

<jsp:include page="/nav.jsp" />

<header class="py-4 bg-white border-bottom mb-4">
  <div class="container">
    <h2 class="fw-bold mb-0">공지 작성</h2>
    <p class="text-muted mb-0">관리자 공지사항을 등록하는 페이지입니다.</p>
  </div>
</header>

<main class="container flex-grow-1 pb-5">

  <% if ("1".equals(request.getParameter("error"))) { %>
    <div class="alert alert-danger">제목과 내용을 모두 입력해주세요.</div>
  <% } %>

  <div class="card shadow-sm">
    <div class="card-body">

      <form action="<%=ctx%>/notice-write" method="post">

        <div class="mb-3">
          <label class="form-label">제목</label>
          <input type="text" name="title" class="form-control" required maxlength="200">
        </div>

        <div class="mb-3">
          <label class="form-label">내용</label>
          <textarea name="content" class="form-control" rows="10" required></textarea>
        </div>

        <div class="d-flex justify-content-between">
          <a href="<%=ctx%>/community.jsp" class="btn btn-outline-secondary">뒤로가기</a>
          <button type="submit" class="btn btn-primary">공지 등록</button>
        </div>

      </form>

    </div>
  </div>

</main>

<footer class="mt-auto py-3 bg-light border-top">
  <div class="container text-center text-muted small">
    &copy; 커뮤니티
  </div>
</footer>

</body>
</html>