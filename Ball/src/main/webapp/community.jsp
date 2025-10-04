<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="java.util.*, java.net.URLEncoder" %>

<!-- 네비/로그인 상태/표시명 등은 header.jsp에서 제공합니다 (loggedIn, displayName 등) -->
<%@ include file="include/header.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    // 이 파일에서만 쓰는 컨텍스트 경로 변수(중복 방지용). header.jsp에 같은 이름이 없어 안전합니다.
    String _ctx = request.getContextPath();

    // 미리보기 모드: /community.jsp?preview=1
    boolean preview = "1".equals(request.getParameter("preview"));

    // 카테고리 화이트리스트
    String category = request.getParameter("category");
    if (category == null || preview) category = "전체";
    List<String> allowed = Arrays.asList("전체","인기글","동네질문");
    if (!allowed.contains(category)) category = "전체";

    // 간이 저장소(애플리케이션 스코프) – DB 붙기 전 임시
    Map<String, List<String>> POSTS = (Map<String, List<String>>) application.getAttribute("POSTS");
    if (POSTS == null) {
        POSTS = new LinkedHashMap<String, List<String>>();
        for (String k : allowed) POSTS.put(k, new ArrayList<String>());
        application.setAttribute("POSTS", POSTS);
    }

    // 현재 카테고리 글 모으기
    List<String> postList;
    if ("전체".equals(category)) {
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

    // 미리보기 + 비로그인: 최대 4개만
    List<String> showList = postList;
    if (preview && !loggedIn) {
        int n = Math.min(4, postList.size());
        showList = new ArrayList<String>(postList.subList(0, n));
    }

    // escape
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

  <!-- 상단 헤더(네비)는 include/header.jsp에서 이미 렌더링됨 -->

  <!-- 페이지 헤더 -->
  <header class="py-5 bg-white border-bottom mb-4">
    <div class="container text-center">
      <h1 class="fw-bold text-primary mb-2"><%= preview ? "커뮤니티 미리보기" : "커뮤니티" %></h1>
      <p class="text-muted mb-0">
        <%= preview ? "최근 게시글 일부만 보여드립니다. 로그인하면 전체 목록과 상세를 볼 수 있어요."
                    : "동네 소식, 질문, 자유글을 나누는 공간입니다." %>
      </p>
    </div>
  </header>

  <!-- 본문 -->
  <main class="container">
    <div class="row">
      <!-- 미리보기일 땐 사이드 메뉴 숨김 / 전체보기일 땐 카테고리 탭 표시 -->
      <% if (!preview || loggedIn) { %>
      <aside class="col-md-3 mb-4">
        <div class="list-group shadow-sm">
          <a href="<%=_ctx%>/community.jsp?category=<%=URLEncoder.encode("전체","UTF-8")%>"
             class="list-group-item list-group-item-action <%= "전체".equals(category) ? "active" : "" %>">전체</a>
          <a href="<%=_ctx%>/community.jsp?category=<%=URLEncoder.encode("인기글","UTF-8")%>"
             class="list-group-item list-group-item-action <%= "인기글".equals(category) ? "active" : "" %>">인기글</a>
          <a href="<%=_ctx%>/community.jsp?category=<%=URLEncoder.encode("동네질문","UTF-8")%>"
             class="list-group-item list-group-item-action <%= "동네질문".equals(category) ? "active" : "" %>">동네질문</a>
        </div>
        <div class="d-grid mt-3">
          <a href="<%= loggedIn ? (_ctx + "/write.jsp?category=" + URLEncoder.encode(category,"UTF-8"))
                                : (_ctx + "/login.jsp?redirect=" + URLEncoder.encode("write.jsp?category=" + category,"UTF-8")) %>"
             class="btn btn-primary">글쓰기</a>
        </div>
      </aside>
      <% } %>

      <section class="<%= (!preview || loggedIn) ? "col-md-9" : "col-md-10 mx-auto" %>">
        <div class="d-flex align-items-center gap-2 mb-2">
          <h4 class="fw-bold mb-0"><%= safeCategory %> 게시글</h4>
          <span class="badge bg-secondary">총 <%= showList.size() %>건</span>
        </div>
        <p class="text-muted small mb-3">
          <%= preview && !loggedIn ? "요약 리스트입니다. 전체 목록과 상세는 로그인 후 확인하세요."
                                   : "카테고리를 바꾸어 다른 글을 확인해보세요." %>
        </p>

        <% if (showList.isEmpty()) { %>
          <div class="alert alert-info">해당 카테고리에는 게시글이 없습니다.</div>
          <% if (preview && !loggedIn) { %>
            <a class="btn btn-outline-primary btn-sm" href="<%=_ctx%>/login.jsp?redirect=<%=URLEncoder.encode("community.jsp","UTF-8")%>">
              첫 글 작성하기
            </a>
          <% } else { %>
            <a class="btn btn-outline-primary btn-sm" href="<%=_ctx%>/write.jsp?category=<%=URLEncoder.encode(category,"UTF-8")%>">
              첫 글 작성하기
            </a>
          <% } %>
        <% } else { %>
          <div class="list-group shadow-sm">
            <%
              for (String title : showList) {
                String safeTitle = (title == null ? "" :
                  title.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
                       .replace("\"","&quot;").replace("'","&#39;"));

                String detailHref;
                if (loggedIn) {
                  detailHref = _ctx + "/post.jsp?title=" + URLEncoder.encode(title, "UTF-8");
                } else {
                  // 비로그인: 상세 보려면 로그인
                  String redirect = "post.jsp?title=" + URLEncoder.encode(title, "UTF-8");
                  detailHref = _ctx + "/login.jsp?redirect=" + URLEncoder.encode(redirect, "UTF-8");
                }
            %>
              <a href="<%=detailHref%>" class="list-group-item list-group-item-action d-flex justify-content-between align-items-center">
                <div>
                  <div class="fw-semibold"><%= safeTitle %></div>
                  <small class="text-muted">미리보기 · 작성자 · 작성시간</small>
                </div>
                <span class="badge bg-light text-dark border">자세히</span>
              </a>
            <% } %>
          </div>

          <% if (preview && !loggedIn) { %>
            <div class="text-center mt-3">
              <a class="btn btn-outline-secondary btn-sm"
                 href="<%=_ctx%>/login.jsp?redirect=<%=URLEncoder.encode("community.jsp","UTF-8")%>">
                로그인하고 전체 보기
              </a>
            </div>
          <% } %>
        <% } %>
      </section>
    </div>
  </main>

  <footer class="site-footer">
    <div class="container text-center">
      <small>Copyright © 플랩풋볼 <%= java.time.Year.now() %></small>
    </div>
  </footer>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
