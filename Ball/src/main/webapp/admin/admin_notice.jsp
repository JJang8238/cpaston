<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dto.User" %>

<%
    // 로그인 / 관리자 체크
    User loginUser = (User) session.getAttribute("loginUser");
    if (loginUser == null || !"admin".equals(loginUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }

    String ctx = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>공지 작성</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body {
            background:#f5f7fa;
            font-family: 'Pretendard','Noto Sans KR',sans-serif;
        }

        /* 상단 파란 제목 바 */
        .page-header {
            background:#0d6efd;
            color:white;
            padding:22px 0;
            margin-bottom:40px;
        }
        .page-header h2 {
            font-size:28px;
            font-weight:700;
        }

        /* 글쓰기 카드 */
        .write-card {
            max-width: 900px;
            margin: auto;
            border:none;
            border-radius:16px;
            box-shadow:0 4px 20px rgba(0,0,0,0.08);
        }

        .write-card .card-header {
            background:#0d6efd;
            color:white;
            font-size:18px;
            font-weight:700;
            padding:16px 20px;
            border-top-left-radius:16px;
            border-top-right-radius:16px;
        }

        .form-label {
            font-weight:600;
        }

        .btn-primary {
            padding:10px 20px;
            font-weight:600;
            border-radius:10px;
        }
        .btn-secondary {
            padding:10px 20px;
            border-radius:10px;
        }
    </style>
</head>

<body class="d-flex flex-column min-vh-100">

<!-- NAV -->
<jsp:include page="/nav.jsp" />

<!-- 상단 타이틀 -->
<div class="page-header text-center">
    <h2>공지 작성</h2>
    <p class="mb-0" style="opacity:0.85;">관리자 공지사항을 등록하는 페이지입니다.</p>
</div>

<main class="container flex-grow-1 pb-5">

    <% if ("1".equals(request.getParameter("error"))) { %>
      <div class="alert alert-danger text-center">제목과 내용을 모두 입력해주세요.</div>
    <% } %>

    <!-- 글쓰기 카드 -->
    <div class="card write-card">
        <div class="card-header">📢 새 공지 작성</div>

        <div class="card-body p-4">

            <form action="<%=ctx%>/notice-write" method="post">

                <div class="mb-3">
                    <label class="form-label">제목</label>
                    <input type="text" name="title" class="form-control form-control-lg" required maxlength="200">
                </div>

                <div class="mb-3">
                    <label class="form-label">내용</label>
                    <textarea name="content" rows="10" class="form-control" style="resize:none;" required></textarea>
                </div>

                <div class="d-flex justify-content-between mt-4">
                    <a href="<%=ctx%>/community.jsp" class="btn btn-secondary">취소</a>
                    <button class="btn btn-primary">공지 등록</button>
                </div>

            </form>

        </div>
    </div>

</main>

<!-- Footer -->
<footer class="mt-auto py-3 bg-light border-top">
    <div class="text-center text-muted small">&copy; 커뮤니티</div>
</footer>

</body>
</html>
