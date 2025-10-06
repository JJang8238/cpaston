<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
request.setCharacterEncoding("UTF-8");
String ctx = request.getContextPath();

// 파라미터 받기
String category = request.getParameter("category");
String title = request.getParameter("title");
if (category == null) category = "전체";
if (title == null || title.isBlank()) {
    out.println("<script>alert('잘못된 접근입니다.'); history.back();</script>");
    return;
}

// 게시글 목록 가져오기
Map<String, List<String>> POSTS = (Map<String, List<String>>) application.getAttribute("POSTS");
if (POSTS == null) {
    out.println("<script>alert('게시글 데이터가 없습니다.'); location.href='" + ctx + "/community.jsp';</script>");
    return;
}

// 게시글 존재 여부 확인
boolean exists = false;
if ("전체".equals(category)) {
    for (List<String> list : POSTS.values()) {
        if (list.contains(title)) { exists = true; break; }
    }
} else {
    List<String> list = POSTS.get(category);
    exists = (list != null && list.contains(title));
}
if (!exists) {
    out.println("<script>alert('존재하지 않는 게시글입니다.'); history.back();</script>");
    return;
}

// 🧩 댓글 저장소 초기화
Map<String, List<String>> COMMENTS = (Map<String, List<String>>) application.getAttribute("COMMENTS");
if (COMMENTS == null) {
    COMMENTS = new LinkedHashMap<>();
    application.setAttribute("COMMENTS", COMMENTS);
}

// 📝 댓글 등록 처리 (POST 요청)
if ("POST".equalsIgnoreCase(request.getMethod())) {
    String newComment = request.getParameter("comment");
    if (newComment != null && !newComment.isBlank()) {
        List<String> commentList = COMMENTS.get(title);
        if (commentList == null) {
            commentList = new ArrayList<>();
            COMMENTS.put(title, commentList);
        }
        commentList.add(newComment.trim());
    }
    // 중복 방지용 리다이렉트
    response.sendRedirect("post.jsp?category=" + java.net.URLEncoder.encode(category, "UTF-8") +
                          "&title=" + java.net.URLEncoder.encode(title, "UTF-8"));
    return;
}

// 현재 댓글 목록
List<String> commentList = COMMENTS.getOrDefault(title, new ArrayList<>());
%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title><%=title%> - 볼피또</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
  <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container">
      <a class="navbar-brand fw-bold" href="<%=ctx%>/index.jsp">볼피또</a>
    </div>
  </nav>

  <main class="container my-5">
    <div class="row justify-content-center">
      <div class="col-md-8">

        <!-- 📰 게시글 -->
        <div class="card shadow-sm mb-4">
          <div class="card-header bg-primary text-white">
            <b><%=title%></b>
          </div>
          <div class="card-body">
            <p class="text-muted mb-2">
              <small>카테고리: <%=category%></small>
            </p>
            <hr>
            <p>(현재는 DB가 없으므로 본문 내용이 없습니다.)</p>
          </div>
        </div>

        <!-- 💬 댓글 목록 -->
        <div class="card shadow-sm mb-4">
          <div class="card-header bg-light">
            <b>댓글 (<%=commentList.size()%>)</b>
          </div>
          <div class="card-body">
            <% if (commentList.isEmpty()) { %>
              <p class="text-muted">아직 댓글이 없습니다.</p>
            <% } else { 
                 for (int i = 0; i < commentList.size(); i++) { %>
              <div class="border-bottom py-2">
                <b>익명</b> <small class="text-muted">#<%=i+1%></small><br>
                <%=commentList.get(i)%>
              </div>
            <% } } %>
          </div>
        </div>

        <!-- ✏️ 댓글 작성 -->
        <div class="card shadow-sm">
          <div class="card-body">
            <form action="post.jsp?category=<%=java.net.URLEncoder.encode(category,"UTF-8")%>&title=<%=java.net.URLEncoder.encode(title,"UTF-8")%>" method="post">
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
          <a href="<%=ctx%>/community.jsp?category=<%=java.net.URLEncoder.encode(category,"UTF-8")%>" class="btn btn-secondary btn-sm">목록으로</a>
        </div>

      </div>
    </div>
  </main>
  <!-- Footer -->
    <footer class="py-5 bg-dark">
        <div class="container px-4 px-lg-5">
            <p class="m-0 text-center text-white">Copyright &copy; 볼피또 2025</p>
        </div>
    </footer>
  
</body>
</html>
