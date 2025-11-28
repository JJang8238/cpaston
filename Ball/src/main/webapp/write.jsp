<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true"%>
<%@ page import="java.util.*" %>
<%@ page import="dto.User" %>
<%@ page import="dao.BoardDAO, dto.Board" %>

<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    // 로그인 확인
    User loginUser = (User) session.getAttribute("loginUser");
    if (loginUser == null) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    // 작성자
    String author = loginUser.getUsername();

    // ⭐ board_id 파라미터 받기
    String param = request.getParameter("board_id");
    int boardId = 1;
    try { boardId = Integer.parseInt(param); } catch (Exception ignore) {}

    // 게시판 목록
    List<Board> boards = new ArrayList<>();
    try (BoardDAO dao = new BoardDAO()) {
        boards = dao.list();
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>글쓰기</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>

<body class="d-flex flex-column min-vh-100 bg-light">

<jsp:include page="/nav.jsp" />

<main class="container my-5 flex-grow-1">

  <div class="row justify-content-center">
    <div class="col-md-8">

      <div class="card shadow-sm">
        <div class="card-header bg-primary text-white">
          <b>새 글 작성</b>
        </div>

        <div class="card-body">

          <form action="<%=ctx%>/write_process.jsp" method="post" class="needs-validation" novalidate>

            <input type="hidden" name="author" value="<%=author%>">

            <!-- 게시판 -->
            <div class="mb-3">
              <label class="form-label">게시판</label>
              <select name="board_id" class="form-select" required>
                <% for (Board b : boards) { %>
                  <option value="<%=b.getId()%>" <%= (b.getId()==boardId ? "selected" : "") %>>
                    <%= b.getName() %>
                  </option>
                <% } %>
              </select>
              <div class="invalid-feedback">게시판을 선택하세요.</div>
            </div>

            <!-- 제목 -->
            <div class="mb-3">
              <label class="form-label">제목</label>
              <input type="text" name="title" class="form-control" maxlength="200" required>
              <div class="invalid-feedback">제목을 입력하세요.</div>
            </div>

            <!-- 내용 -->
            <div class="mb-3">
              <label class="form-label">내용</label>
              <textarea name="content" class="form-control" rows="7" required></textarea>
              <div class="invalid-feedback">내용을 입력하세요.</div>
            </div>

            <div class="d-flex justify-content-between">
              <a class="btn btn-secondary" href="<%=ctx%>/community.jsp?category=<%=boardId%>">취소</a>
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
