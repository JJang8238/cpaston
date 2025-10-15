<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.PostDAO, dto.Post" %>
<%@ page import="java.util.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    // 1) 게시글 ID 파라미터 (필수)
    int id = -1;
    try { id = Integer.parseInt(request.getParameter("id")); } catch(Exception ignore){}
    if (id <= 0) {
        out.println("<script>alert('잘못된 접근입니다.'); location.href='" + ctx + "/community.jsp';</script>");
        return;
    }

    // 2) DB에서 게시글 조회
    Post post = null;
    try (PostDAO dao = new PostDAO()) {
        post = dao.findById(id);
    } catch (Exception e) {
        e.printStackTrace();
    }
    if (post == null) {
        out.println("<script>alert('존재하지 않는 게시글입니다.'); location.href='" + ctx + "/community.jsp';</script>");
        return;
    }

    // 3) 댓글 저장소 (application 스코프, 게시글ID 기준)
    //    Map<게시글ID, List<String>>
    Map<Integer, List<String>> COMMENTS = (Map<Integer, List<String>>) application.getAttribute("COMMENTS_BY_ID");
    if (COMMENTS == null) {
        COMMENTS = new LinkedHashMap<>();
        application.setAttribute("COMMENTS_BY_ID", COMMENTS);
    }

    // 4) 댓글 등록 처리 (POST)
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String newComment = request.getParameter("comment");
        if (newComment != null && !newComment.isBlank()) {
            synchronized (COMMENTS) {
                List<String> list = COMMENTS.get(id);
                if (list == null) {
                    list = new ArrayList<>();
                    COMMENTS.put(id, list);
                }
                list.add(newComment.trim());
            }
        }
        // 새로고침 중복 방지
        response.sendRedirect("post.jsp?id=" + id);
        return;
    }

    // 5) 현재 댓글 목록
    List<String> commentList = COMMENTS.getOrDefault(id, new ArrayList<>());

    // 6) 안전 출력용 이스케이프
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
%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title><%= safeTitle %> - 볼피또</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>

<!-- ✅ 스티키(고정 아님) 레이아웃: 본문이 짧으면 하단 붙고, 길면 문서 끝 -->
<body class="d-flex flex-column min-vh-100 bg-light">
  <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container">
      <a class="navbar-brand fw-bold" href="<%=ctx%>/community.jsp">볼피또</a>
    </div>
  </nav>

  <main class="container flex-grow-1 my-5">
    <div class="row justify-content-center">
      <div class="col-md-8">

        <!-- 📰 게시글 -->
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
                <% if (!safeAuthor.isEmpty()) { %>
                  · 작성자: <%= safeAuthor %>
                <% } %>
              </small>
            </p>
            <hr>
            <div><%= safeContent %></div>
          </div>
        </div>

        <!-- 💬 댓글 목록 -->
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

        <!-- ✏️ 댓글 작성 -->
        <div class="card shadow-sm">
          <div class="card-body">

            <form action="post.jsp?id=<%= id %>" method="post">
              <div class="mb-3">
                <textarea name="comment" class="form-control" rows="3" placeholder="댓글을 입력하세요..." required></textarea>
              </div>
              <div class="d-flex justify-content-end">
                <button type="submit" class="btn btn-primary btn-sm">등록</button>
              </div>
            </form>
          </div>
        </div>

        <!-- 🔙 목록 버튼 -->
        <div class="mt-3 text-end">

          <a href="<%=ctx%>/community.jsp?category=<%= java.net.URLEncoder.encode(post.getCategory(), "UTF-8") %>"
             class="btn btn-secondary btn-sm">목록으로</a>
        </div>

      </div>
    </div>
  </main>

  <footer class="mt-auto py-4 bg-dark text-light">
    <div class="container text-center">
      <small>Copyright &copy; 볼피또 <%= java.time.Year.now() %></small>
    </div>
  </footer>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
