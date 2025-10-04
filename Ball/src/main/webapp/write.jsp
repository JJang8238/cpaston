<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  request.setCharacterEncoding("UTF-8");
  String ctx = request.getContextPath();   // 예: /Ball
  String category = request.getParameter("category");
  if (category == null) category = "전체";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>글쓰기 - 볼피또</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
  <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container">
      <a class="navbar-brand fw-bold" href="<%=ctx%>/index.jsp">볼피또</a>
    </div>
  </nav>

  <main class="container my-5">
    <div class="row justify-content-center">
      <div class="col-md-8">
        <div class="card shadow-sm">
          <div class="card-header bg-primary text-white">
            <b>새 글 작성</b> (<%=category%>)
          </div>
          <div class="card-body">
            <!-- 절대경로: 컨텍스트패스/파일명 -->
            <form action="<%=ctx%>/write_process.jsp" method="post">
              <!-- 카테고리 선택 -->
              <div class="mb-3">
                <label class="form-label">카테고리</label>
                <select name="category" class="form-select" required>
                  <option value="전체" <%= "전체".equals(category) ? "selected" : "" %>>전체</option>
                  <option value="인기글" <%= "인기글".equals(category) ? "selected" : "" %>>인기글</option>
                  <option value="동네질문" <%= "동네질문".equals(category) ? "selected" : "" %>>동네질문</option>
                </select>
              </div>

              <div class="mb-3">
                <label class="form-label">제목</label>
                <input type="text" name="title" class="form-control" required>
              </div>

              <div class="mb-3">
                <label class="form-label">내용</label>
                <textarea name="content" class="form-control" rows="7" required></textarea>
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
</body>
</html>
