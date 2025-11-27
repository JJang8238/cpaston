<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="dao.PostDAO, dto.Post" %>
<%@ page import="dao.NoticeDAO, dto.Notice" %>
<%@ page import="dto.User" %>

<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    User loginUser = (User) session.getAttribute("loginUser");

    String category = request.getParameter("category");
    if (category == null) category = "전체";
    List<String> allowed = Arrays.asList("전체","인기글","동네질문");
    if (!allowed.contains(category)) category = "전체";

    List<Post> posts;
    try (PostDAO dao = new PostDAO()) {
        posts = dao.list(category);
    }

    // XSS 필터링
    String safeCategory = category
        .replace("&","&amp;").replace("<","&lt;")
        .replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;");

    // 📌 최신 공지 1개 가져오기
    Notice notice = null;
    try (NoticeDAO ndao = new NoticeDAO()) {
        notice = ndao.getLatestNotice();
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>커뮤니티</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
body { background:#f8f9fa; }
.best-badge {
  background:#0d6efd !important;
  color:white !important;
  font-weight:bold;
}
.notice-card {
  background:#fff9d6;
  border-left:6px solid #ffc107;
}
</style>
</head>

<body class="d-flex flex-column min-vh-100">

<jsp:include page="/nav.jsp" />

<header class="py-5 bg-white border-bottom mb-4">
  <div class="container text-center">
    <h1 class="fw-bold text-primary mb-2">커뮤니티</h1>
    <p class="text-muted mb-0">동네 소식, 질문, 자유글을 나누는 공간입니다.</p>
  </div>
</header>

<main class="container flex-grow-1 pb-5">

    <!-- 📌 공지사항 카드 -->
    <div class="mb-4">
      <% if (notice != null) { %>
        <div class="card notice-card shadow-sm">
          <div class="card-body">
            <h5 class="fw-bold text-dark mb-1">📢 공지사항</h5>
            <p class="mb-0"><%= notice.getTitle() %></p>
          </div>
        </div>
      <% } else { %>
        <div class="alert alert-warning">📢 현재 등록된 공지사항이 없습니다.</div>
      <% } %>
    </div>

  <div class="row">

    <!-- 좌측 카테고리 -->
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

    <!-- 게시글 목록 -->
    <section class="col-md-9 mb-5">

      <div class="d-flex align-items-center gap-2 mb-2">
        <h4 class="fw-bold mb-0"><%= safeCategory %> 게시글</h4>
        <span class="badge bg-secondary">총 <%= posts.size() %>건</span>
      </div>

      <% if (posts.isEmpty()) { %>
        <div class="alert alert-info">해당 카테고리에 게시글이 없습니다.</div>
      <% } else { %>

      <div class="row row-cols-1 g-3">

      <% for (Post p : posts) {

          String title = (p.getTitle()==null?"":p.getTitle())
              .replace("&","&amp;").replace("<","&lt;")
              .replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;");

          String dateStr = (p.getCreatedAt()==null) ? "" :
            new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(p.getCreatedAt());

          boolean isBest = (p.getLikes() >= 5 && p.getDislikes() <= 3);
      %>

        <div class="col">
          <div class="card h-100 shadow-sm">
            <div class="card-body">

              <!-- 제목 + BEST -->
              <h5 class="card-title text-dark mb-1 d-flex align-items-center gap-2">
                <a href="<%=ctx%>/post.jsp?id=<%=p.getId()%>"
                   class="text-dark text-decoration-none">
                  <%= title %>
                </a>

                <span class="badge best-badge"
                      style="<%= isBest ? "" : "display:none;" %>">BEST</span>
              </h5>

              <p class="text-muted small mb-2">
                <%= p.getAuthor() %> · <%= dateStr %>
              </p>

              <div class="d-flex align-items-center justify-content-between">

                <!-- 좋아요 / 싫어요 -->
                <div class="d-flex align-items-center gap-2">
                  <button class="btn btn-sm btn-outline-primary btn-like"
                          data-id="<%=p.getId()%>">
                    👍 <span class="like-count"><%= p.getLikes() %></span>
                  </button>

                  <button class="btn btn-sm btn-outline-secondary btn-dislike"
                          data-id="<%=p.getId()%>">
                    👎 <span class="dislike-count"><%= p.getDislikes() %></span>
                  </button>
                </div>

                <!-- 신고 버튼 -->
                <button class="btn btn-sm btn-outline-danger btn-report"
                        data-id="<%=p.getId()%>">
                  🚨 신고
                </button>

              </div>

            </div>
          </div>
        </div>

      <% } %>

      </div>
      <% } %>

    </section>
  </div>
</main>

<script>
document.addEventListener("DOMContentLoaded", () => {

  const loginUser = "<%= (loginUser != null ? loginUser.getUsername() : "") %>";

  function sendAction(postId, action, elems) {

    if (!loginUser) {
      alert("로그인 후 이용 가능합니다.");
      return;
    }

    fetch("<%=ctx%>/post-like", {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8" },
      body: new URLSearchParams({ id: postId, action: action })
    })
    .then(res => res.json())
    .then(data => {

      const container = elems.container;

      if (action === "report") {
        if (!data.ok) {
          alert("이미 신고한 게시물입니다.");
          return;
        }
        alert("신고가 접수되었습니다.");
      }

      // 숫자 업데이트
      const likeSpan = container.querySelector(".like-count");
      const dislikeSpan = container.querySelector(".dislike-count");

      if (likeSpan && typeof data.likes === "number") likeSpan.textContent = data.likes;
      if (dislikeSpan && typeof data.dislikes === "number") dislikeSpan.textContent = data.dislikes;

      // BEST 즉시 반영
      const bestBadge = container.querySelector(".best-badge");
      if (bestBadge) {
        const isBest = (data.likes >= 5 && data.dislikes <= 3);
        bestBadge.style.display = isBest ? "inline-block" : "none";
      }

    })
    .catch(err => console.error("post-like 오류:", err));
  }

  document.querySelectorAll(".btn-like").forEach(btn => {
    btn.addEventListener("click", () => {
      const card = btn.closest(".card-body");
      sendAction(btn.dataset.id, "like", { container: card });
    });
  });

  document.querySelectorAll(".btn-dislike").forEach(btn => {
    btn.addEventListener("click", () => {
      const card = btn.closest(".card-body");
      sendAction(btn.dataset.id, "dislike", { container: card });
    });
  });

  document.querySelectorAll(".btn-report").forEach(btn => {
    btn.addEventListener("click", () => {
      const card = btn.closest(".card-body");
      sendAction(btn.dataset.id, "report", { container: card });
    });
  });

});
</script>

</body>
</html>
