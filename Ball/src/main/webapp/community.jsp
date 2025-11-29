<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="dao.PostDAO" %>
<%@ page import="dao.NoticeDAO" %>
<%@ page import="dao.BoardDAO" %>
<%@ page import="dto.User" %>
<%@ page import="dto.Post" %>
<%@ page import="dto.Notice" %>
<%@ page import="dto.Board" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    User loginUser = (User) session.getAttribute("loginUser");

    String categoryParam = request.getParameter("category");
    int categoryId = 1;

    try { categoryId = Integer.parseInt(categoryParam); } catch (Exception ignore) {}

    List<Board> boards = new ArrayList<>();
    try (BoardDAO bdao = new BoardDAO()) {
        boards = bdao.list();
    }

    String categoryName = "전체";
    for (Board b : boards) {
        if (b.getId() == categoryId) {
            categoryName = b.getName();
            break;
        }
    }

    List<Post> posts = new ArrayList<>();

    try (PostDAO dao = new PostDAO()) {
        if (categoryId == 1) {
            posts = dao.listAll();     // 전체
        } else {
            posts = dao.listByBoardId(categoryId);
        }
    }

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
.best-badge { background:#0d6efd !important; color:white !important; font-weight:bold; }
.notice-card { background:#fff9d6; border-left:6px solid #ffc107; }
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

    <!-- 공지사항 -->
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

    <!-- 왼쪽 카테고리 -->
    <aside class="col-md-3 mb-5">

      <div class="list-group shadow-sm">
        <a href="<%=ctx%>/community.jsp?category=1"
           class="list-group-item list-group-item-action <%= (categoryId==1?"active":"") %>">
           전체
        </a>

        <% for (Board b : boards) {
             if (b.getName().equals("전체")) continue;
        %>
          <a href="<%=ctx%>/community.jsp?category=<%=b.getId()%>"
             class="list-group-item list-group-item-action <%= (b.getId()==categoryId ? "active" : "") %>">
             <%= b.getName() %>
          </a>
        <% } %>
      </div>

      <div class="d-grid mt-3">
        <a href="<%=ctx%>/write.jsp?board_id=<%=categoryId%>" class="btn btn-primary">글쓰기</a>
      </div>

    </aside>

    <!-- 게시글 목록 -->
    <section class="col-md-9 mb-5">

      <div class="d-flex align-items-center gap-2 mb-2">
        <h4 class="fw-bold mb-0"><%= categoryName %> 게시글</h4>
        <span class="badge bg-secondary">총 <%= posts.size() %>건</span>
      </div>

      <% if (posts.isEmpty()) { %>
        <div class="alert alert-info">해당 카테고리에 게시글이 없습니다.</div>
      <% } else { %>

      <div class="row row-cols-1 g-3">

      <%
        for (Post p : posts) {

            boolean isReported = false;
            if (loginUser != null) {
                try (PostDAO dao = new PostDAO()) {
                    isReported = dao.didUserReport(p.getId(), loginUser.getId());
                }
            }

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

              <h5 class="card-title d-flex align-items-center gap-2">
                <a href="<%=ctx%>/post.jsp?id=<%=p.getId()%>" class="text-dark text-decoration-none">
                  <%= title %>
                </a>

                <span class="badge best-badge" style="<%= isBest ? "" : "display:none;" %>">BEST</span>
              </h5>

              <p class="text-muted small mb-2"><%= p.getAuthor() %> · <%= dateStr %></p>

              <div class="d-flex align-items-center justify-content-between">

                <!-- 좋아요/싫어요 -->
                <div class="d-flex align-items-center gap-2">
                  <button class="btn btn-sm btn-outline-primary btn-like" data-id="<%=p.getId()%>">
                    👍 <span class="like-count"><%=p.getLikes()%></span>
                  </button>

                  <button class="btn btn-sm btn-outline-secondary btn-dislike" data-id="<%=p.getId()%>">
                    👎 <span class="dislike-count"><%=p.getDislikes()%></span>
                  </button>
                </div>

                <!-- 신고 -->
                <% if (isReported) { %>
                    <button class="btn btn-sm btn-danger" disabled>🚨 신고됨(나)</button>
                <% } else { %>
                    <button class="btn btn-sm btn-outline-danger btn-report" data-id="<%=p.getId()%>">🚨 신고</button>
                <% } %>

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

<!-- ❤️ 좋아요/싫어요/신고 AJAX -->
<script>
document.addEventListener("DOMContentLoaded", function() {

    /* 👍 좋아요 */
    document.querySelectorAll(".btn-like").forEach(btn => {
        btn.addEventListener("click", function() {
            let postId = this.dataset.id;
            let container = this.closest(".card-body");

            fetch("<%=ctx%>/post-like", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: "action=like&id=" + postId
            })
            .then(res => res.json())
            .then(data => updateUI(container)(data));   // ★ 수정됨
        });
    });

    /* 👎 싫어요 */
    document.querySelectorAll(".btn-dislike").forEach(btn => {
        btn.addEventListener("click", function() {
            let postId = this.dataset.id;
            let container = this.closest(".card-body");

            fetch("<%=ctx%>/post-like", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: "action=dislike&id=" + postId
            })
            .then(res => res.json())
            .then(data => updateUI(container)(data));   // ★ 수정됨
        });
    });

    /* 🚨 신고 */
    document.querySelectorAll(".btn-report").forEach(btn => {
        btn.addEventListener("click", function() {

            if (!confirm("이 게시물을 신고하시겠습니까?")) return;

            let postId = this.dataset.id;

            fetch("<%=ctx%>/post-like", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: "action=report&id=" + postId
            })
            .then(res => res.json())
            .then(res => {

                if (res.ok) {
                    alert("신고가 접수되었습니다.");
                    location.reload();
                } else if (res.message === "already") {
                    alert("이미 신고한 게시물입니다.");
                }
            });
        });
    });

    function updateUI(container) {
        return function(data) {
            if (!data.ok) return;

            container.querySelector(".like-count").textContent = data.likes;
            container.querySelector(".dislike-count").textContent = data.dislikes;

            const bestBadge = container.querySelector(".best-badge");
            if (bestBadge) {
                bestBadge.style.display = (data.likes >= 5 && data.dislikes <= 3) ? "inline-block" : "none";
            }
        }
    }

});
</script>

</body>
</html>