<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="dao.PostDAO, dto.Post" %>
<%
  request.setCharacterEncoding("UTF-8");
  String ctx = request.getContextPath();             // 예: /Ball

  // 카테고리
  String category = request.getParameter("category");
  if (category == null) category = "전체";
  List<String> allowed = Arrays.asList("전체","인기글","동네질문");
  if (!allowed.contains(category)) category = "전체";

  // DB에서 목록 조회
  List<Post> posts;
  try (PostDAO dao = new PostDAO()) {
      posts = dao.list(category);
  }

  String safeCategory = category
      .replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
      .replace("\"","&quot;").replace("'","&#39;");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>볼피또 - 커뮤니티</title>

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <style> body { background:#f8f9fa; } .site-footer small{ color:#dee2e6; } </style>
</head>

<body class="d-flex flex-column min-vh-100">

  <!-- 네비 -->
  <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container">
      <a class="navbar-brand fw-bold" href="<%=ctx%>/index.jsp">볼피또</a>
      <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navMain">
        <span class="navbar-toggler-icon"></span>
      </button>
      <div id="navMain" class="collapse navbar-collapse">
        <ul class="navbar-nav ms-auto">
          <li class="nav-item"><a class="nav-link" href="<%=ctx%>/index.jsp">홈</a></li>
          <li class="nav-item"><a class="nav-link active" href="<%=ctx%>/community.jsp">커뮤니티</a></li>
          <li class="nav-item"><a class="nav-link" href="<%=ctx%>/login.jsp">로그인</a></li>
        </ul>
      </div>
    </div>
  </nav>

  <!-- 헤더 -->
  <header class="py-5 bg-white border-bottom mb-4">
    <div class="container text-center">
      <h1 class="fw-bold text-primary mb-2">커뮤니티</h1>
      <p class="text-muted mb-0">동네 소식, 질문, 자유글을 나누는 공간입니다.</p>
    </div>
  </header>

  <!-- 메인 -->
  <main class="container flex-grow-1 pb-5">
    <div class="row">
      <!-- 사이드 -->
      <aside class="col-md-3 mb-5">
        <div class="list-group shadow-sm">
          <a href="<%=ctx%>/community.jsp?category=전체"
             class="list-group-item list-group-item-action <%= "전체".equals(category) ? "active" : "" %>">전체</a>
          <a href="<%=ctx%>/community.jsp?category=인기글"
             class="list-group-item list-group-item-action <%= "인기글".equals(category) ? "active" : "" %>">인기글</a>
          <a href="<%=ctx%>/community.jsp?category=동네질문"
             class="list-group-item list-group-item-action <%= "동네질문".equals(category) ? "active" : "" %>">동네질문</a>
        </div>
        <div class="d-grid mt-3">
          <a href="<%=ctx%>/write.jsp?category=<%=category%>" class="btn btn-primary">글쓰기</a>
        </div>
      </aside>

      <!-- 목록 -->
      <section class="col-md-9 mb-5">
        <div class="d-flex align-items-center gap-2 mb-2">
          <h4 class="fw-bold mb-0"><%= safeCategory %> 게시글</h4>
          <span class="badge bg-secondary">총 <%= posts.size() %>건</span>
        </div>
        <p class="text-muted small mb-4">카테고리를 바꾸어 다른 글을 확인해보세요.</p>

        <% if (posts.isEmpty()) { %>
          <div class="alert alert-info">해당 카테고리에는 게시글이 없습니다.</div>
        <% } else { %>
          <div class="row row-cols-1 g-3">
            <% for (Post p : posts) {
                 String title = (p.getTitle()==null?"":p.getTitle())
                     .replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
                     .replace("\"","&quot;").replace("'","&#39;");
                 String dateStr = (p.getCreatedAt()==null) ? "" :
                     new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(p.getCreatedAt());
            %>
              <div class="col">
                <div class="card h-100 shadow-sm">
                  <div class="card-body">
                    <a href="<%=ctx%>/post.jsp?id=<%=p.getId()%>" class="stretched-link text-decoration-none">
                      <h5 class="card-title text-dark mb-1"><%= title %></h5>
                    </a>
                    <p class="card-text text-muted small mb-0">
                      <%= p.getAuthor() %> · <%= dateStr %>
                    </p>
                  </div>
                </div>
              </div>
            <% } %>
          </div>
        <% } %>
      </section>
    </div>
  </main>

  <!-- 푸터 -->
  <footer class="mt-auto py-4 bg-dark text-light">
    <div class="container text-center">
      <small>Copyright © 플랩풋볼 <%= java.time.Year.now() %></small>
    </div>
  </footer>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
