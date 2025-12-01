<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="dao.PostDAO, dao.NoticeDAO, dao.BoardDAO" %>
<%@ page import="dto.User, dto.Post, dto.Notice, dto.Board" %>

<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    User loginUser = (User) session.getAttribute("loginUser");

    String categoryParam = request.getParameter("category");
    int categoryId = 1;
    try { categoryId = Integer.parseInt(categoryParam); } catch (Exception ignore) {}

    List<Board> boards = new ArrayList<>();
    try (BoardDAO bdao = new BoardDAO()) { boards = bdao.list(); }

    String categoryName = "전체";
    for (Board b : boards) if (b.getId() == categoryId) categoryName = b.getName();

    List<Post> posts = new ArrayList<>();
    try (PostDAO dao = new PostDAO()) {
        if (categoryId == 1) posts = dao.listAll();
        else posts = dao.listByBoardId(categoryId);
    }

    Notice notice = null;
    try (NoticeDAO ndao = new NoticeDAO()) { notice = ndao.getLatestNotice(); }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>커뮤니티</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- ⭐⭐ UI/UX 전용 CSS (기능 절대 수정 X) ⭐⭐ -->
<style>
    body {
        background:#f3f4f6;
        font-family:'Pretendard', sans-serif;
    }

    header h1 {
        font-size:2.3rem;
        font-weight:700;
        color:#0d6efd;
    }

    /* 컨테이너 넓게 (졸업작품 느낌) */
    .container-xl {
        max-width:1300px;
    }

    /* 공지 박스 */
    .notice-card {
        background:#fffceb;
        border:1px solid #ffe39f;
        border-radius:12px;
        padding:18px 24px;
        cursor:pointer;
        transition:.15s;
    }
    .notice-card:hover {
        background:#fff6d3;
    }

    /* 카테고리 박스 (네이버 스타일 + 더 큼직하게) */
    .category-box {
        background:white;
        border:1px solid #e5e7eb;
        border-radius:14px;
        padding:20px;
    }
    .category-box .list-group-item {
        border:none;
        padding:15px 20px;
        margin-bottom:6px;
        font-size:16px;
        border-radius:10px !important;
    }
    .category-box .list-group-item.active {
        background:#0d6efd !important;
        color:white !important;
        font-weight:600;
    }
    .category-box .list-group-item:not(.active):hover {
        background:#eef4ff;
        color:#0d6efd;
    }

    .btn-write {
        border-radius:10px;
        font-weight:600;
        padding:12px;
        width:100%;
        margin-top:12px;
    }

    /* 게시글 리스트 (네이버 스타일 + 서비스형) */
    .post-item {
        background:white;
        border-radius:12px;
        border:1px solid #e5e7eb;
        padding:20px 22px;
        display:flex;
        align-items:center;
        transition:.15s;
        margin-bottom:14px;
    }
    .post-item:hover {
        background:#fafbfd;
        box-shadow:0 3px 10px rgba(0,0,0,0.06);
    }

    .post-title {
        font-size:18px;
        font-weight:600;
        color:#111;
        text-decoration:none;
    }
    .post-title:hover {
        color:#0d6efd;
    }

    .post-meta {
        font-size:14px;
        color:#666;
        margin-top:6px;
    }

    .post-actions {
        margin-left:auto;
        display:flex;
        gap:6px;
    }

    .btn-like, .btn-dislike, .btn-report {
        padding:4px 10px;
        font-size:13px;
        border-radius:8px;
    }

    .badge-best {
        background:#0d6efd;
        color:white;
        font-size:11px;
        padding:3px 6px;
        border-radius:4px;
        margin-left:4px;
    }
</style>

</head>


<body class="d-flex flex-column min-vh-100">

<jsp:include page="/nav.jsp" />

<header class="py-5 bg-white border-bottom mb-4">
  <div class="container-xl text-center">
    <h1>커뮤니티</h1>
    <p class="text-muted">동네 소식, 질문, 자유글을 나누는 공간입니다.</p>
  </div>
</header>

<main class="container-xl pb-5">

    <!-- 공지 -->
    <div class="mb-4">
      <% if (notice != null) { %>
        <div class="notice-card shadow-sm">
            <h5 class="fw-bold mb-1">📢 공지사항</h5>
            <p class="mb-0"><%= notice.getTitle() %></p>
        </div>
      <% } else { %>
        <div class="alert alert-warning">📢 현재 등록된 공지사항이 없습니다.</div>
      <% } %>
    </div>

    <div class="row">

        <!-- 왼쪽 카테고리 -->
        <aside class="col-md-3 mb-4">
            <div class="category-box shadow-sm">

                <a href="<%=ctx%>/community.jsp?category=1"
                    class="list-group-item list-group-item-action <%= (categoryId==1?"active":"") %>">
                    전체
                </a>

                <% for (Board b : boards) {
                     if ("전체".equals(b.getName())) continue;
                %>
                    <a href="<%=ctx%>/community.jsp?category=<%=b.getId()%>"
                       class="list-group-item list-group-item-action <%= (b.getId()==categoryId ? "active" : "") %>">
                       <%= b.getName() %>
                    </a>
                <% } %>

            </div>

            <a href="<%=ctx%>/write.jsp?board_id=<%=categoryId%>" class="btn btn-primary btn-write">
                글쓰기
            </a>
        </aside>

        <!-- 게시글 목록 -->
        <section class="col-md-9">

            <h4 class="fw-bold mb-3 d-flex align-items-center gap-2">
                <%= categoryName %> 게시글
                <span class="badge bg-secondary">총 <%= posts.size() %>건</span>
            </h4>

            <% if (posts.isEmpty()) { %>
                <div class="alert alert-info">해당 카테고리에 게시글이 없습니다.</div>
            <% } else { %>

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

                    String dateStr =
                        (p.getCreatedAt()==null) ? "" :
                        new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(p.getCreatedAt());

                    boolean isBest = (p.getLikes() >= 5 && p.getDislikes() <= 3);
                %>

                <div class="post-item">

                    <div class="flex-grow-1">
                        <a href="<%=ctx%>/post.jsp?id=<%=p.getId()%>" class="post-title"><%= title %></a>
                        <% if (isBest) { %>
                            <span class="badge-best">BEST</span>
                        <% } %>

                        <div class="post-meta">
                            <%= p.getAuthor() %> · <%= dateStr %>
                        </div>
                    </div>

                    <div class="post-actions">
                        <button class="btn btn-sm btn-outline-primary btn-like" data-id="<%=p.getId()%>">
                            👍 <span class="like-count"><%=p.getLikes()%></span>
                        </button>

                        <button class="btn btn-sm btn-outline-secondary btn-dislike" data-id="<%=p.getId()%>">
                            👎 <span class="dislike-count"><%=p.getDislikes()%></span>
                        </button>

                        <% if (isReported) { %>
                            <button class="btn btn-sm btn-danger" disabled>🚨</button>
                        <% } else { %>
                            <button class="btn btn-sm btn-outline-danger btn-report" data-id="<%=p.getId()%>">🚨</button>
                        <% } %>
                    </div>

                </div>

                <% } %>
            <% } %>

        </section>

    </div>

</main>

<!-- AJAX 기능 (수정 X) -->
<script>
document.addEventListener("DOMContentLoaded", function() {

    function updateUI(container) {
        return function(data) {
            if (!data.ok) return;
            container.querySelector(".like-count").textContent = data.likes;
            container.querySelector(".dislike-count").textContent = data.dislikes;
        }
    }

    document.querySelectorAll(".btn-like").forEach(btn=>{
        btn.addEventListener("click", function(){
            let id = this.dataset.id;
            let card = this.closest(".post-item");
            fetch("<%=ctx%>/post-like",{
                method:"POST",
                headers:{ "Content-Type":"application/x-www-form-urlencoded" },
                body:"action=like&id="+id
            })
            .then(r=>r.json())
            .then(updateUI(card));
        });
    });

    document.querySelectorAll(".btn-dislike").forEach(btn=>{
        btn.addEventListener("click", function(){
            let id = this.dataset.id;
            let card = this.closest(".post-item");
            fetch("<%=ctx%>/post-like",{
                method:"POST",
                headers:{ "Content-Type":"application/x-www-form-urlencoded" },
                body:"action=dislike&id="+id
            })
            .then(r=>r.json())
            .then(updateUI(card));
        });
    });

    document.querySelectorAll(".btn-report").forEach(btn=>{
        btn.addEventListener("click", function(){
            if(!confirm("이 게시물을 신고하시겠습니까?")) return;
            let id = this.dataset.id;

            fetch("<%=ctx%>/post-like",{
                method:"POST",
                headers:{ "Content-Type":"application/x-www-form-urlencoded" },
                body:"action=report&id="+id
            })
            .then(r=>r.json())
            .then(res=>{
                if(res.ok){
                    alert("신고가 접수되었습니다.");
                    location.reload();
                } else {
                    alert("이미 신고한 게시글입니다.");
                }
            });
        });
    });

});
</script>

</body>
</html>
