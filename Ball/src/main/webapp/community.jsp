<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.net.URLEncoder" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();             // 예: /Ball

    // 1) 카테고리 화이트리스트
    String category = request.getParameter("category");
    if (category == null) category = "전체";
    List<String> allowed = Arrays.asList("전체","인기글","동네질문");
    if (!allowed.contains(category)) category = "전체";

    // 2) 임시 저장소(Map) – DB 전까지 application 스코프 사용
    Map<String, List<String>> POSTS = (Map<String, List<String>>) application.getAttribute("POSTS");
    if (POSTS == null) {
        POSTS = new LinkedHashMap<String, List<String>>();
        for (String k : allowed) POSTS.put(k, new ArrayList<String>());
        application.setAttribute("POSTS", POSTS);
    }

    // 3) 현재 카테고리 목록 준비
    List<String> postList;
    if ("전체".equals(category)) {
        // 모든 카테고리의 글을 합쳐서(중복 제거, 입력 순서 유지)
        LinkedHashSet<String> merged = new LinkedHashSet<String>();
        for (Map.Entry<String, List<String>> e : POSTS.entrySet()) {
            List<String> lst = e.getValue();
            if (lst != null) merged.addAll(lst);
        }
        postList = new ArrayList<String>(merged);
    } else {
        List<String> lst = POSTS.get(category);
        postList = (lst == null) ? Collections.<String>emptyList() : lst;
    }

    // 4) 간단 이스케이프(변수만 사용)
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

  <!-- 고정 푸터 -->
  <style>
    :root { --footer-h: 56px; }
    html, body { height: 100%; }
    body { background:#f8f9fa; padding-bottom: var(--footer-h); }
    .site-footer{
      position:fixed; left:0; right:0; bottom:0; height:var(--footer-h);
      background:#212529; color:#adb5bd; display:flex; align-items:center; justify-content:center;
      z-index:1030;
    }
    .site-footer small{ color:#dee2e6; }
  </style>
</head>
<body>

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
  <main class="container">
    <div class="row">
      <!-- 사이드 -->
      <aside class="col-md-3 mb-4">
        <div class="list-group shadow-sm">
          <a href="<%=ctx%>/community.jsp?category=<%=URLEncoder.encode("전체","UTF-8")%>"
             class="list-group-item list-group-item-action <%= "전체".equals(category) ? "active" : "" %>">전체</a>
          <a href="<%=ctx%>/community.jsp?category=<%=URLEncoder.encode("인기글","UTF-8")%>"
             class="list-group-item list-group-item-action <%= "인기글".equals(category) ? "active" : "" %>">인기글</a>
          <a href="<%=ctx%>/community.jsp?category=<%=URLEncoder.encode("동네질문","UTF-8")%>"
             class="list-group-item list-group-item-action <%= "동네질문".equals(category) ? "active" : "" %>">동네질문</a>
        </div>
        <div class="d-grid mt-3">
          <a href="<%=ctx%>/write.jsp?category=<%=URLEncoder.encode(category,"UTF-8")%>" class="btn btn-primary">글쓰기</a>
        </div>
      </aside>

      <!-- 목록 -->
      <section class="col-md-9">
        <div class="d-flex align-items-center gap-2 mb-2">
          <h4 class="fw-bold mb-0"><%= safeCategory %> 게시글</h4>
          <span class="badge bg-secondary">총 <%= postList.size() %>건</span>
        </div>
        <p class="text-muted small mb-4">카테고리를 바꾸어 다른 글을 확인해보세요.</p>

        <% if (postList.isEmpty()) { %>
          <div class="alert alert-info">해당 카테고리에는 게시글이 없습니다.</div>
        <% } else { %>
          <div class="row row-cols-1 g-3">
            <%
              for (String title : postList) {
                String safeTitle = (title == null ? "" :
                    title.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
                         .replace("\"","&quot;").replace("'","&#39;"));
                String href = ctx + "/post.jsp?title=" + URLEncoder.encode(title, "UTF-8");
            %>
              <div class="col">
                <div class="card h-100 shadow-sm">
                  <div class="card-body">
                    <a href="<%= href %>" class="stretched-link text-decoration-none">
                      <h5 class="card-title text-dark mb-1"><%= safeTitle %></h5>
                    </a>
                    <p class="card-text text-muted small mb-0">내용 미리보기…</p>
                  </div>
                </div>
              </div>
            <% } %>
          </div>
        <% } %>
      </section>
    </div>
  </main>

  <!-- 고정 푸터 -->
  <footer class="site-footer">
    <div class="container text-center">
      <small>Copyright © 플랩풋볼 <%= java.time.Year.now() %></small>
    </div>
  </footer>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
