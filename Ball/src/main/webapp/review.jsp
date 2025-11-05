<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="dto.User" %>
<%
    // 로그인 체크
    Object _loginObj = session.getAttribute("loginUser");
    if (_loginObj == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    User loginUser = null;
    String displayName = null;

    if (_loginObj instanceof User) {
        loginUser = (User) _loginObj;
        displayName = (loginUser.getName() != null && !loginUser.getName().isEmpty()) ? loginUser.getName() : "사용자";
    } else {
        displayName = String.valueOf(_loginObj);
    }

    String ctx = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>리뷰 페이지</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="<%=ctx%>/css/styles.css" rel="stylesheet" />
</head>
<body>

<!-- ✅ 네비게이션 -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container px-5">
        <a class="navbar-brand" href="<%=ctx%>/main.jsp">볼피또</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse"
                data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false"
                aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav ms-auto mb-2 mb-lg-0">
                <li class="nav-item">
                    <span class="nav-link disabled"><%= displayName %>님 환영합니다</span>
                </li>
                <li class="nav-item"><a class="nav-link" href="<%=ctx%>/main.jsp">홈</a></li>
                <li class="nav-item"><a class="nav-link" href="<%=ctx%>/mypage.jsp">마이페이지</a></li>
                <li class="nav-item"><a class="nav-link" href="<%=ctx%>/logout.jsp">로그아웃</a></li>
            </ul>
        </div>
    </div>
</nav>

<!-- ✅ 메인 컨텐츠 -->
<div class="container mt-5 mb-5">
    <h2 class="fw-bold mb-4 text-center">경기 리뷰 게시판</h2>

    <!-- 📝 리뷰 작성 폼 -->
    <div class="card mb-4 shadow-sm">
        <div class="card-header bg-primary text-white">리뷰 작성</div>
        <div class="card-body">
            <form action="saveReview.jsp" method="post">
                <div class="mb-3">
                    <label for="matchTitle" class="form-label">경기명</label>
                    <input type="text" class="form-control" id="matchTitle" name="matchTitle" placeholder="예: 14:00 서울 풋살장 경기" required>
                </div>
                <div class="mb-3">
                    <label for="rating" class="form-label">평점 (1~5)</label>
                    <select class="form-select" id="rating" name="rating" required>
                        <option value="">선택</option>
                        <option value="5">★★★★★ (5점)</option>
                        <option value="4">★★★★☆ (4점)</option>
                        <option value="3">★★★☆☆ (3점)</option>
                        <option value="2">★★☆☆☆ (2점)</option>
                        <option value="1">★☆☆☆☆ (1점)</option>
                    </select>
                </div>
                <div class="mb-3">
                    <label for="content" class="form-label">리뷰 내용</label>
                    <textarea class="form-control" id="content" name="content" rows="4" placeholder="경기에 대한 후기를 자유롭게 작성해주세요." required></textarea>
                </div>
                <input type="hidden" name="writer" value="<%= displayName %>">
                <button type="submit" class="btn btn-primary">등록</button>
            </form>
        </div>
    </div>

   
</body>
</html>

