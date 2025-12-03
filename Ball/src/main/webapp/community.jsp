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
            posts = dao.listAll();
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
    body {
        background-color: #f5f7fa;
    }
    .page-header-wrap {
        background: #ffffff;
        border-bottom: 1px solid #e5e7eb;
    }
    .page-header-inner {
        padding: 32px 0;
    }
    .page-title {
        font-weight: 700;
        font-size: 26px;
        margin-bottom: 6px;
    }
    .page-subtitle {
        color: #6b7280;
        font-size: 14px;
    }
    .notice-card {
        background:#fff9db;
        border: none;
        border-radius: 16px;
        border-left: 5px solid #facc15;
        cursor:pointer;
        box-shadow: 0 4px 14px rgba(0,0,0,0.04);
    }
    .category-card {
        border-radius: 16px;
        box-shadow: 0 4px 14px rgba(0,0,0,0.05);
        border: none;
        background:#ffffff;
    }
    .category-title {
        font-weight: 600;
        font-size: 15px;
        margin-bottom: 10px;
    }
    .list-group-item {
        border: none;
        border-radius: 10px !important;
        margin-bottom: 4px;
        font-size: 14px;
    }
    .list-group-item.active {
        background:#0d6efd;
        border-color:#0d6efd;
    }
    .write-btn {
        border-radius: 10px;
        font-weight: 600;
    }
    .post-header-row {
        margin-bottom: 14px;
    }
    .post-header-row h4 {
        font-size: 20px;
    }
    .post-card {
        border-radius: 16px;
        border: none;
        box-shadow: 0 4px 16px rgba(15,23,42,0.06);
        background:#ffffff;
    }
    .post-card .card-title a {
        font-size: 17px;
        font-weight: 600;
    }
    .post-meta {
        color:#6b7280;
        font-size: 13px;
    }
    .best-badge {
        background:#0d6efd !important;
        color:white !important;
        font-weight:bold;
        padding:3px 8px;
        border-radius:999px;
        font-size:11px;
    }
    .btn-like, .btn-dislike, .btn-report {
        border-radius: 999px;
        font-size: 13px;
        padding: 4px 10px;
    }
</style>
</head>

<body class="d-flex flex-column min-vh-100">

<jsp:include page="/nav.jsp" />

<!-- 상단 타이틀 영역 -->
<div class="page-header-wrap">
  <div class="container page-header-inner">
    <h2 class="page-title mb-1">커뮤니티</h2>
    <p class="page-subtitle mb-0">동네 소식, 질문, 자유글을 나누는 공간입니다.</p>
  </div>
</div>

<main class="container flex-grow-1 py-4 pb-5">

    <!-- 공지사항 카드 -->
    <div class="mb-4">
      <% if (notice != null) { %>
        <div class="card notice-card" onclick="openNoticeModal(<%=notice.getId()%>)">
          <div class="card-body d-flex align-items-center justify-content-between">
            <div>
              <h6 class="fw-bold text-dark mb-1">📢 공지사항</h6>
              <p class="mb-0 small text-muted"><%= notice.getTitle() %></p>
            </div>
            <span class="text-secondary small">자세히 보기 &raquo;</span>
          </div>
        </div>
      <% } else { %>
        <div class="alert alert-warning mb-0">📢 현재 등록된 공지사항이 없습니다.</div>
      <% } %>
    </div>

    <!-- 관리자 공지 작성 버튼 -->
    <% if (loginUser != null && "admin".equals(loginUser.getRole())) { %>
        <div class="mb-3 text-end">
            <a href="<%=ctx%>/admin/admin_notice.jsp" class="btn btn-sm btn-warning rounded-pill px-3">공지 작성</a>
        </div>
    <% } %>

    <div class="row g-4">

      <!-- 카테고리 사이드 -->
      <aside class="col-lg-3">
        <div class="card category-card p-3">
          <div class="category-title mb-2">카테고리</div>
          <div class="list-group">

            <a href="<%=ctx%>/community.jsp?category=1"
               class="list-group-item list-group-item-action <%= (categoryId==1?"active":"") %>">
               전체
            </a>

            <% for (Board b : boards) {
                 if ("전체".equals(b.getName())) continue;
            %>
              <a href="<%=ctx%>/community.jsp?category=<%=b.getId()%>"
                 class="list-group-item list-group-item-action <%= (b.getId()==categoryId?"active":"") %>">
                 <%= b.getName() %>
              </a>
            <% } %>
          </div>

          <div class="d-grid mt-3">
            <a href="<%=ctx%>/write.jsp?board_id=<%=categoryId%>" class="btn btn-primary write-btn">
              글쓰기
            </a>
          </div>
        </div>
      </aside>

      <!-- 게시글 목록 -->
      <section class="col-lg-9">

        <div class="post-header-row d-flex align-items-center justify-content-between">
          <div class="d-flex align-items-center gap-2">
            <h4 class="fw-bold mb-0"><%= categoryName %> 게시글</h4>
            <span class="badge text-bg-secondary">총 <%= posts.size() %>건</span>
          </div>
        </div>

        <% if (posts.isEmpty()) { %>

          <div class="card post-card p-4">
            <p class="mb-0 text-muted">해당 카테고리에 게시글이 없습니다.</p>
          </div>

        <% } else { %>

          <div class="row row-cols-1 g-3">

          <% for (Post p : posts) {

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
              <div class="card post-card h-100">
                <div class="card-body">

                  <h5 class="card-title d-flex align-items-center gap-2 mb-1">
                    <a href="<%=ctx%>/post.jsp?id=<%=p.getId()%>" class="text-dark text-decoration-none">
                      <%= title %>
                    </a>
                    <span class="best-badge" style="<%= isBest ? "" : "display:none;" %>">BEST</span>
                  </h5>

                  <p class="post-meta mb-3">
                    <span><%= p.getAuthor() %></span>
                    <span class="mx-1">·</span>
                    <span><%= dateStr %></span>
                  </p>

                  <div class="d-flex align-items-center justify-content-between mt-1">
                    <div class="d-flex align-items-center gap-2">
                      <button class="btn btn-sm btn-outline-primary btn-like" data-id="<%=p.getId()%>">
                        👍 <span class="like-count"><%=p.getLikes()%></span>
                      </button>

                      <button class="btn btn-sm btn-outline-secondary btn-dislike" data-id="<%=p.getId()%>">
                        👎 <span class="dislike-count"><%=p.getDislikes()%></span>
                      </button>
                    </div>

                    <% if (isReported) { %>
                        <button class="btn btn-sm btn-danger btn-report" disabled>🚨 신고됨(나)</button>
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

<!-- 공지 상세보기 모달 -->
<!-- 📌 새 커뮤니티 스타일 공지사항 모달 -->
<div class="modal fade" id="noticeModal">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content" style="border-radius:18px; border:none; box-shadow:0 8px 28px rgba(15,23,42,0.2);">

      <!-- Modal Header -->
      <div class="modal-header" style="border-bottom:1px solid #e5e7eb;">
        <h5 class="modal-title fw-bold">📢 공지사항</h5>
        <button class="btn-close" data-bs-dismiss="modal"></button>
      </div>

      <!-- Modal Body -->
      <div class="modal-body py-4 px-4" id="noticeBody" style="font-size:15px; line-height:1.6;">
        불러오는 중...
      </div>

      <!-- Footer -->
      <div class="modal-footer" style="border-top:1px solid #e5e7eb;">
        <button class="btn btn-secondary rounded-pill px-4" data-bs-dismiss="modal">닫기</button>
      </div>

    </div>
  </div>
</div>


<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<!-- 좋아요/싫어요/신고 + 공지 팝업 JS -->
<script>
function openNoticeModal(id) {
    fetch("<%=ctx%>/notice?id=" + id)
        .then(res => res.text())
        .then(html => {
            document.getElementById("noticeBody").innerHTML = html;
            new bootstrap.Modal(document.getElementById("noticeModal")).show();
        });
}

document.addEventListener("DOMContentLoaded", function() {

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
            .then(data => updateUI(container)(data));
        });
    });

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
            .then(data => updateUI(container)(data));
        });
    });

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
                bestBadge.style.display =
                    (data.likes >= 5 && data.dislikes <= 3) ? "inline-block" : "none";
            }
        }
    }
});
</script>

</body>
</html>