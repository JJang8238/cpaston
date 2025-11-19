<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.PostDAO, dto.Post, dto.User" %>

<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    // 로그인 체크
    User loginUser = (User) session.getAttribute("loginUser");
    if (loginUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String loginUsername = loginUser.getUsername();

    // 게시글 ID 파라미터
    int id = -1;
    try { id = Integer.parseInt(request.getParameter("id")); } catch (Exception ignore) {}
    if (id <= 0) {
        out.println("<script>alert('잘못된 접근입니다.'); location.href='" + ctx + "/community.jsp';</script>");
        return;
    }

    // 🔥 어디에서 왔는지 (mypage 또는 community)
    String from = request.getParameter("from");
    if (from == null) from = "community";

    // 기존 게시글 조회
    Post post = null;
    try (PostDAO dao = new PostDAO()) {
        post = dao.findById(id);
    }
    if (post == null) {
        out.println("<script>alert('존재하지 않는 게시글입니다.'); location.href='" + ctx + "/community.jsp';</script>");
        return;
    }

    // 작성자 체크
    if (!loginUsername.equals(post.getAuthor())) {
        out.println("<script>alert('본인이 작성한 글만 수정할 수 있습니다.'); history.back();</script>");
        return;
    }

    // 기존 값
    String title = post.getTitle();
    String content = post.getContent();
    String category = post.getCategory();
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>글 수정 - 볼피또</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>

<body class="d-flex flex-column min-vh-100 bg-light">

<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container">
        <a class="navbar-brand fw-bold" href="<%=ctx%>/community.jsp">볼피또</a>
    </div>
</nav>

<main class="container my-5 flex-grow-1">
    <div class="row justify-content-center">
        <div class="col-md-8">

            <div class="card shadow-sm">
                <div class="card-header bg-warning text-dark fw-bold">
                    글 수정하기
                </div>

                <div class="card-body">

                    <form action="<%=ctx%>/updatePost" method="post" class="needs-validation" novalidate>

                        <!-- 게시글 ID -->
                        <input type="hidden" name="id" value="<%=post.getId()%>">

                        <!-- 🔥 어디에서 왔는지 전달 (중요!!) -->
                        <input type="hidden" name="from" value="<%=from%>">

                        <!-- 카테고리 -->
                        <div class="mb-3">
                            <label class="form-label">카테고리</label>
                            <select name="category" class="form-select" required>
                                <option value="전체"     <%= "전체".equals(category) ? "selected" : "" %>>전체</option>
                                <option value="인기글"   <%= "인기글".equals(category) ? "selected" : "" %>>인기글</option>
                                <option value="동네질문" <%= "동네질문".equals(category) ? "selected" : "" %>>동네질문</option>
                            </select>
                            <div class="invalid-feedback">카테고리를 선택해 주세요.</div>
                        </div>

                        <!-- 제목 -->
                        <div class="mb-3">
                            <label class="form-label">제목</label>
                            <input type="text" name="title" class="form-control"
                                   value="<%=title%>" maxlength="200" required>
                            <div class="invalid-feedback">제목을 입력해 주세요.</div>
                        </div>

                        <!-- 내용 -->
                        <div class="mb-3">
                            <label class="form-label">내용</label>
                            <textarea name="content" class="form-control" rows="8" required><%=content%></textarea>
                            <div class="invalid-feedback">내용을 입력해 주세요.</div>
                        </div>

                        <!-- 버튼 -->
                        <div class="d-flex justify-content-between">
                            <a href="<%=ctx%>/post.jsp?id=<%=post.getId()%>&from=<%=from%>" class="btn btn-secondary">취소</a>
                            <button type="submit" class="btn btn-warning text-dark fw-bold">수정 완료</button>
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
                if (!form.checkValidity()) {
                    event.preventDefault();
                    event.stopPropagation();
                }
                form.classList.add('was-validated');
            }, false);
        });
    })();
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
