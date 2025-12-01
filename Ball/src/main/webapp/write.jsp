<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true"%>
<%@ page import="java.util.*" %>
<%@ page import="dto.User" %>
<%@ page import="dao.BoardDAO" %>
<%@ page import="dto.Board" %>

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
  <title>글쓰기 - 볼피또</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

  <style>
    body {
      background: linear-gradient(135deg, #f3f5fb 0%, #e9f1ff 35%, #f6f7fb 100%);
      font-family: 'Pretendard', system-ui, -apple-system, BlinkMacSystemFont, sans-serif;
    }

    .page-wrapper {
      max-width: 1100px;
      margin: 40px auto 60px auto;
    }

    /* 상단 타이틀 영역 */
    .page-header-box {
      margin-bottom: 18px;
    }
    .page-title {
      font-size: 26px;
      font-weight: 700;
      color: #222;
    }
    .page-subtitle {
      font-size: 14px;
      color: #6c757d;
    }

    /* 메인 카드 - 대시보드 느낌 */
    .editor-layout {
      border-radius: 18px;
      overflow: hidden;
      box-shadow: 0 10px 30px rgba(15, 23, 42, 0.12);
      background: #ffffff;
      border: 1px solid rgba(148, 163, 184, 0.35);
    }

    .editor-sidebar {
      background: #0d6efd;
      color: white;
      padding: 22px 22px 24px 22px;
    }
    .editor-sidebar h6 {
      font-size: 15px;
      font-weight: 700;
      margin-bottom: 10px;
    }
    .editor-sidebar p {
      font-size: 13px;
      opacity: 0.9;
    }
    .editor-sidebar ul {
      padding-left: 18px;
      margin-bottom: 0;
      font-size: 13px;
    }

    .editor-main {
      padding: 22px 26px 24px 26px;
      background: #ffffff;
    }

    /* 폼 요소 디자인 업그레이드 */
    .form-label {
      font-weight: 600;
      font-size: 14px;
      color: #374151;
    }
    .form-control, .form-select {
      border-radius: 10px;
      border-color: #d1d5db;
      font-size: 14px;
    }
    .form-control:focus, .form-select:focus {
      border-color: #0d6efd;
      box-shadow: 0 0 0 0.15rem rgba(13,110,253,.18);
    }

    textarea.form-control {
      min-height: 220px;
      resize: vertical;
    }

    .editor-main hr {
      margin: 18px 0 20px 0;
      opacity: 0.4;
    }

    /* 버튼 영역 */
    .btn-primary {
      border-radius: 999px;
      padding: 7px 22px;
      font-size: 14px;
    }
    .btn-secondary {
      border-radius: 999px;
      padding: 7px 20px;
      font-size: 14px;
      background:#6b7280;
      border-color:#6b7280;
    }
    .btn-secondary:hover {
      background:#4b5563;
      border-color:#4b5563;
    }

    /* 푸터 */
    footer {
      font-size: 13px;
    }

    @media (max-width: 768px) {
      .editor-layout {
        border-radius: 0;
      }
      .editor-sidebar {
        border-bottom: 1px solid rgba(148,163,184,0.4);
      }
    }
  </style>
</head>
<body class="d-flex flex-column min-vh-100">
  <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container">
      <a class="navbar-brand fw-bold" href="<%=ctx%>/index.jsp">볼피또</a>
    </div>
  </nav>

  <main class="flex-grow-1">
    <div class="page-wrapper">

      <!-- 상단 타이틀/설명 -->
      <div class="page-header-box">
        <div class="d-flex justify-content-between align-items-end flex-wrap">
          <div>
            <div class="page-title">커뮤니티 글쓰기</div>
            <div class="page-subtitle">
              볼피또 커뮤니티에 새로운 이야기를 공유해 주세요. (현재 카테고리: <b><%=category%></b>)
            </div>
          </div>
          <div class="text-muted small mt-2 mt-sm-0">
            작성자: <b><%=author%></b>
          </div>
        </div>
      </div>

      <!-- 에디터 레이아웃 -->
      <div class="editor-layout row g-0">
        <!-- 좌측 사이드 정보 -->
        <div class="col-md-3 editor-sidebar">
          <h6>작성 가이드</h6>
          <p class="mb-2">원활한 커뮤니티 운영을 위해 아래 내용을 지켜주세요.</p>
          <ul class="mb-3">
            <li>욕설 및 비방, 광고성 글 금지</li>
            <li>개인정보(전화번호, 주소 등) 노출 주의</li>
            <li>경기 모집 시 장소·시간을 명확히 기입</li>
          </ul>
          <p class="mt-2 mb-0">
            작성된 글은 운영자의 판단에 따라 숨김 또는 삭제될 수 있습니다.
          </p>
        </div>

        <!-- 우측 폼 영역 -->
        <div class="col-md-9 editor-main">
          <form action="<%=ctx%>/write_process.jsp" method="post" class="needs-validation" novalidate>
            <input type="hidden" name="author" value="<%=author%>">

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
              <input type="text" name="title" class="form-control" maxlength="200" required
                     placeholder="예) 일요일 저녁 풋살 매칭 인원 모집합니다.">
              <div class="invalid-feedback">제목을 입력해 주세요.</div>
            </div>

            <!-- 내용 -->
            <div class="mb-1">
              <label class="form-label">내용</label>
              <textarea name="content" class="form-control" rows="7" required
                        placeholder="경기 일정, 장소, 실력 수준, 준비물 등 자세히 적어주세요."></textarea>
              <div class="invalid-feedback">내용을 입력해 주세요.</div>
            </div>

            <hr>

            <!-- 버튼 영역 -->
            <div class="d-flex justify-content-between align-items-center mt-2">
              <a class="btn btn-secondary"
                 href="<%=ctx%>/community.jsp?category=<%=java.net.URLEncoder.encode(category,"UTF-8")%>">취소</a>
              <button type="submit" class="btn btn-primary">등록</button>
            </div>
          </form>
        </div>
      </div>

    </div>
  </div>

  <footer class="mt-auto py-4 bg-dark text-light">
  <div class="container text-center">

      <div class="mb-1" style="font-size: 20px; font-weight: 700;">
          ⚽ Ballpitto – Play Together, Enjoy More
      </div>

      <div class="small text-secondary">
          📍 위치 기반 경기 매칭&nbsp;&nbsp;|&nbsp;&nbsp;
          👥 파트너 찾기&nbsp;&nbsp;|&nbsp;&nbsp;
          📝 리뷰 & 커뮤니티
      </div>

  </div>
</footer>

</body>
</html>