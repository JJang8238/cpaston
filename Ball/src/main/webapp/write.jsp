<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true"%>
<%@ page import="dto.User" %>
<%
  request.setCharacterEncoding("UTF-8");
  String ctx = request.getContextPath();   // 예: /Ball

  // 카테고리 기본값
  String category = request.getParameter("category");
  if (category == null || category.isEmpty()) category = "전체";

  // 작성자 (세션에서 추출: dto.User 또는 문자열)
  Object obj = session.getAttribute("loginUser");
  if (obj == null) { response.sendRedirect("login.jsp"); return; }
  String author = "guest";
  if (obj instanceof User) {
    try { author = ((User)obj).getUsername(); } catch (Exception ignore) {}
    if (author == null || author.isEmpty()) {
      try { author = ((User)obj).getName(); } catch (Exception ignore) {}
    }
  } else {
    author = String.valueOf(obj);
  }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>글쓰기 - 볼피또</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="d-flex flex-column min-vh-100 bg-light">
  <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container">
      <a class="navbar-brand fw-bold" href="<%=ctx%>/index.jsp">볼피또</a>
    </div>
  </nav>

  <main class="container my-5 flex-grow-1">
    <div class="row justify-content-center">
      <div class="col-md-8">
        <div class="card shadow-sm">
          <div class="card-header bg-primary text-white">
            <b>새 글 작성</b> (<%=category%>)
          </div>
          <div class="card-body">
            <form action="<%=ctx%>/write_process.jsp" method="post" class="needs-validation" novalidate>
              <input type="hidden" name="author" value="<%=author%>">

              <div class="mb-3">
                <label class="form-label">카테고리</label>
                <select name="category" class="form-select" required>
                  <option value="전체"     <%= "전체".equals(category) ? "selected" : "" %>>전체</option>
                  <option value="인기글"   <%= "인기글".equals(category) ? "selected" : "" %>>인기글</option>
                  <option value="동네질문" <%= "동네질문".equals(category) ? "selected" : "" %>>동네질문</option>
                </select>
                <div class="invalid-feedback">카테고리를 선택해 주세요.</div>
              </div>

              <div class="mb-3">
                <label class="form-label">제목</label>
                <input type="text" name="title" class="form-control" maxlength="200" required>
                <div class="invalid-feedback">제목을 입력해 주세요.</div>
              </div>

              <div class="mb-3">
                <label class="form-label">내용</label>
                <textarea name="content" class="form-control" rows="7" required></textarea>
                <div class="invalid-feedback">내용을 입력해 주세요.</div>
              </div>

              <div class="d-flex justify-content-between">
                <a class="btn btn-secondary"
                   href="<%=ctx%>/community.jsp?category=<%=java.net.URLEncoder.encode(category,"UTF-8")%>">취소</a>
                <button type="submit" class="btn btn-primary">등록</button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  </main>

  <footer class="mt-auto py-4 bg-dark text-light">
    <div class="container text-center"><small>Copyright © 볼피또 2025</small></div>
  </footer>

  <script>
  (function() {
    'use strict';
    const forms = document.querySelectorAll('.needs-validation');
    Array.prototype.slice.call(forms).forEach(function(form) {
      form.addEventListener('submit', function (event) {
        if (!form.checkValidity()) { event.preventDefault(); event.stopPropagation(); }
        form.classList.add('was-validated');
      }, false);
    });
  })();
  </script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
