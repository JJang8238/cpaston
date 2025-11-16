<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.PostDAO, dto.Post" %>
<%@ page import="dto.User" %>
<%@ page import="java.util.*" %>

<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    // 로그인 유저 정보
    User loginUser = (User) session.getAttribute("loginUser");
    String loginUsername = (loginUser != null) ? loginUser.getUsername() : null;

    // from 파라미터 (community / mypage 구분)
    String from = request.getParameter("from");
    if (from == null) from = "community";

    // 게시글 ID
    int id = -1;
    try { id = Integer.parseInt(request.getParameter("id")); } catch(Exception ignore){}
    if (id <= 0) {
        out.println("<script>alert('잘못된 접근입니다.'); location.href='" + ctx + "/community.jsp';</script>");
        return;
    }

    // DB 조회
    Post post = null;
    try (PostDAO dao = new PostDAO()) { post = dao.findById(id); }
    if (post == null) {
        out.println("<script>alert('존재하지 않는 게시글입니다.'); location.href='" + ctx + "/community.jsp';</script>");
        return;
    }

    // 댓글 저장소
    Map<Integer, List<String>> COMMENTS = (Map<Integer, List<String>>) application.getAttribute("COMMENTS_BY_ID");
    if (COMMENTS == null) {
        COMMENTS = new LinkedHashMap<>();
        application.setAttribute("COMMENTS_BY_ID", COMMENTS);
    }

    // 댓글 등록
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

    // 댓글 목록
    List<String> commentList = COMMENTS.getOrDefault(id, new ArrayList<>());

    // 안전 출력
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

    // 🔥 목록으로 버튼 설정
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
          <div class="card-header bg-primary text-white">
            <b><%= safeTitle %></b>
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

            <!-- 수정/삭제 버튼 -->
            <% if (loginUsername != null && loginUsername.equals(post.getAuthor())) { %>
            <div class="d-flex justify-content-end gap-2 mt-4">

              <!-- 수정 -->
              <a href="<%=ctx%>/edit.jsp?id=<%=post.getId()%>&from=<%=from%>"
                 class="btn btn-sm btn-warning">수정</a>

              <!-- 삭제 -->
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

        <!-- 목록 버튼 -->
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

</body>
</html>
