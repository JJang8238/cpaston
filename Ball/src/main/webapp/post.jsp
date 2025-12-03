<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.PostDAO, dto.Post" %>
<%@ page import="dto.User" %>
<%@ page import="java.util.*" %>

<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    User loginUser = (User) session.getAttribute("loginUser");
    String loginUsername = (loginUser != null) ? loginUser.getUsername() : null;

    String from = request.getParameter("from");
    if (from == null) from = "community";

    int id = -1;
    try { id = Integer.parseInt(request.getParameter("id")); } catch(Exception ignore){}
    if (id <= 0) {
        out.println("<script>alert('잘못된 접근입니다.'); location.href='" + ctx + "/community.jsp';</script>");
        return;
    }

    Post post = null;
    try (PostDAO dao = new PostDAO()) { post = dao.findById(id); }
    if (post == null) {
        out.println("<script>alert('존재하지 않는 게시글입니다.'); location.href='" + ctx + "/community.jsp';</script>");
        return;
    }

    boolean isBest = (post.getLikes() >= 5 && post.getDislikes() <= 3);

    // 댓글 저장(임시)
    Map<Integer, List<String>> COMMENTS = (Map<Integer, List<String>>) application.getAttribute("COMMENTS_BY_ID");
    if (COMMENTS == null) {
        COMMENTS = new LinkedHashMap<>();
        application.setAttribute("COMMENTS_BY_ID", COMMENTS);
    }

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String newComment = request.getParameter("comment");
        if (newComment != null && !newComment.isBlank()) {
            synchronized (COMMENTS) {
                COMMENTS.computeIfAbsent(id, k -> new ArrayList<>()).add(newComment.trim());
            }
        }
        response.sendRedirect("post.jsp?id=" + id + "&from=" + from);
        return;
    }

    List<String> commentList = COMMENTS.getOrDefault(id, new ArrayList<>());

    String safeTitle = (post.getTitle()==null?"":post.getTitle())
        .replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
        .replace("\"","&quot;").replace("'","&#39;");
    String safeBoardName = post.getBoardName();
    String safeAuthor = post.getAuthor();
    String safeContent = (post.getContent()==null?"":post.getContent())
        .replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
        .replace("\n","<br/>");

    String backUrl = ("mypage".equals(from))
        ? ctx + "/mypage.jsp"
        : ctx + "/community.jsp?board=" + post.getBoardId();
%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title><%= safeTitle %> - 볼피또</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
    body {
        background:#f5f6f8;
        font-family:'Pretendard','Noto Sans KR',sans-serif;
    }

    .card-modern {
        border-radius:20px;
        background:white;
        padding:28px;
        border:1px solid #e6e6e6;
        box-shadow:0 4px 14px rgba(0,0,0,0.06);
    }

    .like-btn, .dislike-btn {
        border-radius:25px;
        padding:6px 14px;
        border:1px solid #d0d7ff;
        background:white;
        transition:0.2s;
        font-size:14px;
    }
    .like-btn:hover { background:#ebf2ff; border-color:#9cbcff; }
    .dislike-btn:hover { background:#f5f5f5; border-color:#bfbfbf; }

    .report-btn {
        border-radius:25px;
        padding:6px 14px;
        border:1px solid #ffb7c5;
        background:#ffe4ea;
        transition:0.2s;
        font-size:14px;
        color:#d63048;
        font-weight:600;
    }
    .report-btn:hover {
        background:#ffccd5;
        border-color:#ff97a9;
        color:#c71f38;
    }

    .edit-btn {
        border-radius:10px;
        padding:6px 14px;
        background:#ffcc00;
        border:none;
        font-size:14px;
        font-weight:600;
    }
    .delete-btn {
        border-radius:10px;
        padding:6px 14px;
        background:#ff6b6b;
        border:none;
        font-size:14px;
        color:white;
        font-weight:600;
    }

    textarea {
        resize:vertical;
        border-radius:12px;
    }
</style>

</head>

<body class="d-flex flex-column min-vh-100">

<!-- ⭐ community.jsp와 완전 동일한 네비바 적용 -->
<jsp:include page="/nav.jsp" />

<main class="container my-5" style="max-width:1000px;">

    <h3 class="fw-bold mb-4">게시글 보기</h3>

    <!-- 게시글 카드 -->
    <div class="card-modern mb-4">

        <div class="d-flex justify-content-between align-items-center mb-2">
            <h4 class="fw-bold m-0"><%= safeTitle %></h4>

            <% if (isBest) { %>
                <span class="badge bg-success bg-opacity-10 text-success fw-bold px-3 py-2">
                    BEST
                </span>
            <% } %>
        </div>

        <div class="text-muted small mb-3">
            게시판: <%= safeBoardName %>
            · 작성자: <%= safeAuthor %>
            <% if (post.getCreatedAt() != null) { %>
                · <%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(post.getCreatedAt()) %>
            <% } %>
        </div>

        <hr>

        <div style="font-size:17px; line-height:1.7;">
            <%= safeContent %>
        </div>

        <div class="mt-4 d-flex align-items-center gap-2">
            <button class="like-btn" id="btnLike">
                👍 좋아요 <span id="likeCount"><%= post.getLikes() %></span>
            </button>

            <button class="dislike-btn" id="btnDislike">
                👎 싫어요 <span id="dislikeCount"><%= post.getDislikes() %></span>
            </button>

            <% if (post.getReports() < 7) { %>
                <button class="report-btn" id="btnReport">🚨 신고하기</button>
            <% } else { %>
                <span class="badge bg-danger">🚨 신고 누적됨</span>
            <% } %>

            <span class="text-muted small ms-2">
                <% if (loginUsername == null) { %> 로그인 후 가능 <% } %>
            </span>
        </div>

        <% if (loginUsername != null && loginUsername.equals(post.getAuthor())) { %>
            <div class="d-flex justify-content-end gap-2 mt-4">
                <a href="<%=ctx%>/edit.jsp?id=<%=post.getId()%>&from=<%=from%>" class="edit-btn">수정</a>

                <form action="<%=ctx%>/deletePost" method="post"
                      onsubmit="return confirm('정말 삭제하시겠습니까?');">
                    <input type="hidden" name="postId" value="<%=post.getId()%>">
                    <button class="delete-btn">삭제</button>
                </form>
            </div>
        <% } %>

    </div>

    <!-- 댓글 목록 -->
    <div class="card-modern mb-4">
        <h5 class="fw-bold mb-3">댓글 (<%= commentList.size() %>)</h5>

        <% if (commentList.isEmpty()) { %>
            <p class="text-muted mb-0">아직 댓글이 없습니다.</p>
        <% } else {
            for (int i=0; i<commentList.size(); i++) {
                String c = commentList.get(i).replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
                                           .replace("\n","<br/>");
        %>
            <div class="border-bottom py-2">
                <b class="text-primary">익명</b>
                <small class="text-muted"> #<%=i+1%></small><br>
                <%= c %>
            </div>
        <% } } %>
    </div>

    <!-- 댓글 입력 -->
    <div class="card-modern mb-3">
        <form action="post.jsp?id=<%=id%>&from=<%=from%>" method="post">
            <textarea name="comment" rows="3" class="form-control" required></textarea>
            <div class="d-flex justify-content-end mt-2">
                <button class="btn btn-primary px-3">등록</button>
            </div>
        </form>
    </div>

    <!-- 목록으로 -->
    <div class="text-end">
        <a href="<%=backUrl%>" class="btn btn-secondary">목록으로</a>
    </div>

</main>

<script>
const loginUser = "<%= (loginUsername != null ? loginUsername : "") %>";

function sendAction(type) {
    if (!loginUser) return alert("로그인 후 이용 가능합니다.");

    fetch("<%=ctx%>/post-like", {
        method: "POST",
        headers: { "Content-Type":"application/x-www-form-urlencoded; charset=UTF-8" },
        body: new URLSearchParams({ id:"<%=id%>", action:type })
    })
    .then(res=>res.json())
    .then(data=>{
        if (!data.ok) return alert("처리 중 오류");

        document.getElementById("likeCount").textContent = data.likes;
        document.getElementById("dislikeCount").textContent = data.dislikes;
    })
}

document.getElementById("btnLike").onclick = ()=>sendAction("like");
document.getElementById("btnDislike").onclick = ()=>sendAction("dislike");
const r = document.getElementById("btnReport");
if (r) r.onclick = ()=>sendAction("report");
</script>

</body>
</html>