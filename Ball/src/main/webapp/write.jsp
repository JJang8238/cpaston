<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true"%>
<%@ page import="dto.User" %>
<%
  request.setCharacterEncoding("UTF-8");
  String ctx = request.getContextPath();   // 예: /Ball

    // 로그인 확인
    User loginUser = (User) session.getAttribute("loginUser");
    if (loginUser == null) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    String author = loginUser.getUsername();

    // board_id 파라미터 받기
    String param = request.getParameter("board_id");
    int boardId = 1;
    try { boardId = Integer.parseInt(param); } catch (Exception ignore) {}

    // 게시판 목록
    List<Board> boards = new ArrayList<>();
    try (BoardDAO dao = new BoardDAO()) {
        boards = dao.list();
    }
  } else {
    author = String.valueOf(obj);
  }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>새 글 작성 - 볼피또</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
    body {
        background:#f5f6f8;
        font-family:'Pretendard','Noto Sans KR', sans-serif;
    }

    .write-card {
        border-radius:16px;
        border:1px solid #e8e8e8;
        background:white;
        padding:28px;
    }

    .form-label {
        font-weight:600;
        margin-bottom:6px;
    }

    .title-text {
        font-size:28px;
        font-weight:700;
        margin-bottom:24px;
    }

    textarea {
        resize: vertical;
    }
</style>
</head>

<body>

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

<main class="container my-5" style="max-width:850px;">

    <!-- 페이지 제목 -->
    <h3 class="fw-bold mb-4">새 글 작성</h3>

    <!-- 카드 -->
    <div class="write-card shadow-sm">

        <form action="<%=ctx%>/write_process.jsp" method="post">

            <input type="hidden" name="author" value="<%=author%>">

            <!-- 게시판 선택 -->
            <div class="mb-4">
                <label class="form-label">게시판</label>
                <select name="board_id" class="form-select" required>
                    <% for (Board b : boards) { %>
                      <option value="<%=b.getId()%>" <%= (b.getId()==boardId ? "selected" : "") %>>
                        <%= b.getName() %>
                      </option>
                    <% } %>
                </select>
            </div>

            <!-- 제목 -->
            <div class="mb-4">
                <label class="form-label">제목</label>
                <input type="text" name="title" class="form-control" required maxlength="200">
            </div>

            <!-- 내용 -->
            <div class="mb-4">
                <label class="form-label">내용</label>
                <textarea name="content" class="form-control" rows="10" required></textarea>
            </div>

            <!-- 버튼 -->
            <div class="d-flex justify-content-end gap-2">
                <a class="btn btn-outline-secondary" href="<%=ctx%>/community.jsp?category=<%=boardId%>">취소</a>
                <button type="submit" class="btn btn-primary px-4">등록</button>
            </div>

        </form>

    </div>

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
