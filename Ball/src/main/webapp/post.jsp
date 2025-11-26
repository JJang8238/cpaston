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
    String safeCategory = (post.getCategory()==null?"":post.getCategory())
            .replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
            .replace("\"","&quot;").replace("'","&#39;");
    String safeAuthor = (post.getAuthor()==null?"":post.getAuthor())
            .replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
            .replace("\"","&quot;").replace("'","&#39;");
    String safeContent = (post.getContent()==null?"":post.getContent())
            .replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
            .replace("\"","&quot;").replace("'","&#39;")
            .replace("\n","<br/>");

    String backUrl =
        "mypage".equals(from)
        ? ctx + "/mypage.jsp"
        : ctx + "/community.jsp?category=" + java.net.URLEncoder.encode(post.getCategory(),"UTF-8");
%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title><%= safeTitle %> - 볼피또</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>

<body class="d-flex flex-column min-vh-100 bg-light">

  <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container">
      <a class="navbar-brand fw-bold" href="<%=ctx%>/community.jsp">볼피또</a>
    </div>
  </nav>

  <main class="container flex-grow-1 my-5">
    <div class="row justify-content-center">
      <div class="col-md-8">

        <!-- 게시글 -->
        <div class="card shadow-sm mb-4">
          <div class="card-header bg-primary text-white d-flex align-items-center justify-content-between">
            <b><%= safeTitle %></b>
            <span id="bestBadge"
                  class="badge bg-light text-success"
                  style="<%= isBest ? "" : "display:none;" %>">
              BEST
            </span>
          </div>

          <div class="card-body">
            <p class="text-muted mb-2">
              <small>
                카테고리: <%= safeCategory %>
                <% if (post.getCreatedAt() != null) { %>
                  · 작성일: <%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(post.getCreatedAt()) %>
                <% } %>
                · 작성자: <%= safeAuthor %>
              </small>
            </p>
            <hr>
            <div><%= safeContent %></div>

            <!-- 좋아요 / 싫어요 / 신고 -->
            <div class="mt-4 d-flex align-items-center gap-2">
              <div class="btn-group btn-group-sm" role="group">

                <button type="button" class="btn btn-outline-primary" id="btnLike">
                  👍 좋아요 <span id="likeCount"><%= post.getLikes() %></span>
                </button>

                <button type="button" class="btn btn-outline-secondary" id="btnDislike">
                  👎 싫어요 <span id="dislikeCount"><%= post.getDislikes() %></span>
                </button>

              </div>

              <% if (post.getReports() < 7) { %>
                <button type="button" class="btn btn-sm btn-outline-danger" id="btnReport">
                  🚨 신고하기
                </button>
              <% } else { %>
                <span class="badge bg-danger ms-1" id="reportBadge">🚨 신고 누적됨</span>
              <% } %>

              <small class="text-muted ms-2">
                <% if (loginUsername == null) { %>
                  로그인 후 투표/신고할 수 있습니다.
                <% } else { %>
                  좋아요/싫어요/신고로 게시글을 평가해 보세요!
                <% } %>
              </small>
            </div>

            <!-- 수정/삭제 -->
            <% if (loginUsername != null && loginUsername.equals(post.getAuthor())) { %>
            <div class="d-flex justify-content-end gap-2 mt-4">
              <a href="<%=ctx%>/edit.jsp?id=<%=post.getId()%>&from=<%=from%>"
                 class="btn btn-sm btn-warning">수정</a>

              <form action="<%=ctx%>/deletePost" method="post"
                    onsubmit="return confirm('정말 삭제하시겠습니까?');">
                <input type="hidden" name="postId" value="<%=post.getId()%>">
                <input type="hidden" name="from"   value="<%=from%>">
                <button type="submit" class="btn btn-sm btn-danger">삭제</button>
              </form>
            </div>
            <% } %>

          </div>
        </div>

        <!-- 댓글 -->
        <div class="card shadow-sm mb-4">
          <div class="card-header bg-light">

            <b>댓글 (<%= commentList.size() %>)</b>
          </div>
          <div class="card-body">
            <% if (commentList.isEmpty()) { %>
              <p class="text-muted">아직 댓글이 없습니다.</p>
            <% } else {
                 for (int i = 0; i < commentList.size(); i++) {
                    String c = commentList.get(i)
                        .replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
                        .replace("\"","&quot;").replace("'","&#39;")
                        .replace("\n","<br/>");
            %>
              <div class="border-bottom py-2">
                <b>익명</b> <small class="text-muted">#<%= i+1 %></small><br>
                <%= c %>
              </div>
            <% } } %>
          </div>
        </div>

        <!-- 댓글 입력 -->
        <div class="card shadow-sm">
          <div class="card-body">

            <form action="post.jsp?id=<%=id%>&from=<%=from%>" method="post">
              <textarea name="comment" class="form-control" rows="3" required></textarea>
              <div class="d-flex justify-content-end mt-2">

                <button type="submit" class="btn btn-primary btn-sm">등록</button>
              </div>
            </form>
          </div>
        </div>

        <div class="mt-3 text-end">

          <a href="<%=backUrl%>" class="btn btn-secondary btn-sm">목록으로</a>

        </div>

      </div>
    </div>
  </main>

  <footer class="mt-auto py-4 bg-dark text-light">
    <div class="container text-center">
      <small>Copyright © 볼피또 <%= java.time.Year.now() %></small>
    </div>
  </footer>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

  <script>
    const loginUser = "<%= (loginUsername != null ? loginUsername : "") %>";

    function sendAction(type) {
      if (!loginUser) {
        alert("로그인 후 이용 가능합니다.");
        return;
      }

      fetch("<%=ctx%>/post-like", {
        method: "POST",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
        },
        body: new URLSearchParams({
          id: "<%=id%>",
          action: type
        })
      })
      .then(res => res.json())
      .then(data => {
        if (!data.ok) {
          if (type === "report") {
            alert("이미 신고했거나 처리 중 오류가 발생했습니다.");
          } else {
            alert("처리 중 오류가 발생했습니다.");
          }
          return;
        }

        // 좋아요/싫어요 카운트 갱신
        if (type === "like" || type === "dislike") {
          document.getElementById("likeCount").textContent = data.likes;
          document.getElementById("dislikeCount").textContent = data.dislikes;

          // BEST 뱃지 토글
          const bestBadge = document.getElementById("bestBadge");
          const isBest = (data.likes >= 5 && data.dislikes <= 3);
          bestBadge.style.display = isBest ? "inline-block" : "none";
        }

        // 신고 처리
        if (type === "report") {
          alert("신고가 접수되었습니다.");
          if (data.reports >= 7) {
            const btnReport = document.getElementById("btnReport");
            if (btnReport) {
              btnReport.style.display = "none";
              const badge = document.createElement("span");
              badge.id = "reportBadge";
              badge.className = "badge bg-danger ms-1";
              badge.textContent = "🚨 신고 누적됨";
              btnReport.parentElement.appendChild(badge);
            }
          }
        }
      })
      .catch(() => alert("서버 오류가 발생했습니다."));
    }

    document.getElementById("btnLike").addEventListener("click", (e) => {
      e.preventDefault();
      e.stopPropagation();
      sendAction("like");
    });

    document.getElementById("btnDislike").addEventListener("click", (e) => {
      e.preventDefault();
      e.stopPropagation();
      sendAction("dislike");
    });

    const btnReport = document.getElementById("btnReport");
    if (btnReport) {
      btnReport.addEventListener("click", (e) => {
        e.preventDefault();
        e.stopPropagation();
        sendAction("report");
      });
    }
  </script>

</body>
</html>
