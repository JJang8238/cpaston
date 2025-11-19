
<%@ page contentType="text/html; charset=UTF-8" language="java" pageEncoding="UTF-8" session="true" %>
<%@ page import="java.util.*, java.net.URLEncoder" %>
<%@ page import="dao.MatchDAO, dto.Match" %>
<%@ page import="dao.PostDAO, dto.Post" %>

<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    // 로그인 체크
    Object userObj = session.getAttribute("loginUser");
    String username = (String) session.getAttribute("username");
    boolean loggedIn = (userObj != null) || (username != null);

    // ▼ 오늘 경기 5개만 표시
    MatchDAO matchDAO = new MatchDAO();
    List<Match> matchList = matchDAO.getTodayMatches();
    if (matchList.size() > 5) matchList = matchList.subList(0, 5);

    // 오늘 날짜
    java.time.LocalDate today = java.time.LocalDate.now();
    java.time.format.DateTimeFormatter fmt = java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd (E)");
    String todayStr = today.format(fmt);

    // ▼ 선택된 카드 (matches / community / reviews)
    String v = request.getParameter("v");
    if (v == null) v = "matches";

    // 버튼 스타일 토글
    String btnMatches = v.equals("matches")   ? "btn-primary" : "btn-outline-primary";
    String btnComm    = v.equals("community") ? "btn-primary" : "btn-outline-primary";
    String btnReview  = v.equals("reviews")   ? "btn-primary" : "btn-outline-primary";

    // ▼ 커뮤니티 최신 4개 (PostDAO 사용, post 테이블에서 가져옴)
    List<Post> previewPosts;
    try (PostDAO pdao = new PostDAO()) {
        // 전체 글에서 최신순으로 가져오고, 4개만 잘라 사용
        previewPosts = pdao.list("전체");
    }
    if (previewPosts == null) {
        previewPosts = new ArrayList<>();
    }
    if (previewPosts.size() > 4) {
        previewPosts = previewPosts.subList(0, 4);
    }

    // 로그인 유도 URL (리뷰용)
    String loginForReview = ctx + "/login.jsp?redirect=" + URLEncoder.encode("reviews.jsp", "UTF-8");
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="utf-8" />

    <title>볼피또</title>
    <link href="<%=ctx%>/css/styles.css" rel="stylesheet" />
    <style>
        .preview-card .list-group-item { display:flex; justify-content:space-between; align-items:center; }
        .section-muted { color:#6c757d; }
    </style>
</head>
<body>

<!-- NAV -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container px-5">
        <a class="navbar-brand" href="<%=ctx%>/index.jsp">볼피또</a>
        <ul class="navbar-nav ms-auto">
            <li class="nav-item"><a class="nav-link active" href="<%=ctx%>/index.jsp">Home</a></li>
            <li class="nav-item"><a class="nav-link" href="<%=ctx%>/login.jsp">로그인</a></li>
            <li class="nav-item"><a class="nav-link" href="<%=ctx%>/register.jsp">회원가입</a></li>
        </ul>
    </div>
</nav>

<!-- HERO -->
<div class="container px-4 px-lg-5">

    <div class="row gx-4 gx-lg-5 align-items-center my-5">
        <div class="col-lg-7">
            <img class="img-fluid rounded mb-4 mb-lg-0" src="<%=ctx%>/assets/img/football.png" />
        </div>
        <div class="col-lg-5">
            <h1 class="fw-bold">우리의 운동 플랫폼</h1>
            <p class="text-muted">경기 매칭 중심 서비스입니다.</p>
            <a class="btn btn-primary" href="<%=ctx%>/register.jsp">지금 참여하기</a>
        </div>
    </div>

    <!-- 기능 카드 -->
    <div class="row text-center mb-4">

        <!-- 경기 매칭 -->
        <div class="col-md-4">
            <div class="card h-100 shadow-sm">
                <div class="card-body">
                    <h3>경기 매칭</h3>
                    <p class="text-muted">원하는 지역에서 경기를 즐겨보세요.</p>
                    <a href="<%=ctx%>/index.jsp?v=matches#preview" class="btn <%=btnMatches%>">자세히 보기</a>
                </div>
            </div>
        </div>

        <!-- 커뮤니티 -->
        <div class="col-md-4 mt-3 mt-md-0">
            <div class="card h-100 shadow-sm">
                <div class="card-body">
                    <h3>커뮤니티</h3>
                    <p class="text-muted">자유롭게 소통하고 정보를 나눠보세요.</p>
                    <a href="<%=ctx%>/index.jsp?v=community#preview" class="btn <%=btnComm%>">자세히 보기</a>
                </div>
            </div>
        </div>

        <!-- 리뷰 -->
        <div class="col-md-4 mt-3 mt-md-0">
            <div class="card h-100 shadow-sm">
                <div class="card-body">
                    <h3>리뷰</h3>
                    <p class="text-muted">경기 참여 후 솔직한 리뷰를 남겨보세요.</p>
                    <a href="<%=ctx%>/index.jsp?v=reviews#preview" class="btn <%=btnReview%>">자세히 보기</a>
                </div>
            </div>
        </div>

    </div>

    <!-- ▼ 프리뷰 -->
    <div id="preview" class="preview-card mb-5">

    <%-- ---------------------- 경기 매칭 PREVIEW ---------------------- --%>
    <% if ("matches".equals(v)) { %>

        <h2 class="fw-bold mb-1">오늘의 경기 예약 현황</h2>
        <p class="text-muted"><%=todayStr%></p>

        <div class="list-group shadow-sm">
        <% if (matchList.isEmpty()) { %>
            <div class="alert alert-info">오늘은 등록된 경기가 없습니다.</div>
        <% } else {
            for (Match m : matchList) { %>
                <div class="list-group-item list-group-item-action">
                    <div>
                        <div class="h5 mb-1"><%= m.getMatchTime() %> 경기</div>
                        <small class="section-muted">
                            <%= m.getLocation() %> | 인원: <%= m.getCurrentPlayers() %> / <%= m.getMaxPlayers() %>
                        </small>
                    </div>
                    <span class="badge bg-success rounded-pill">예약중</span>
                </div>
        <% } } %>
        </div>

    <%-- ---------------------- 커뮤니티 PREVIEW ---------------------- --%>
    <% } else if ("community".equals(v)) { %>

        <h2 class="fw-bold mb-3">커뮤니티 미리보기</h2>

        <% if (previewPosts.isEmpty()) { %>
            <div class="alert alert-info">등록된 게시글이 없습니다.</div>
        <% } else { %>

            <div class="list-group shadow-sm mb-3">
            <%
                java.text.SimpleDateFormat df = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm");
                for (Post p : previewPosts) {
                    String title = (p.getTitle() == null ? "" : p.getTitle())
                                   .replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
                                   .replace("\"","&quot;").replace("'","&#39;");
                    String dateStr = (p.getCreatedAt() == null) ? "" : df.format(p.getCreatedAt());
            %>
                <div class="list-group-item d-flex justify-content-between">
                    <span><%= title %> (작성자: <%= p.getAuthor() %>, <%= dateStr %>)</span>
                    <a class="btn btn-outline-secondary btn-sm" href="<%=ctx%>/login.jsp">자세히</a>
                </div>
            <% } %>
            </div>

        <% } %>

    <%-- ---------------------- 리뷰 PREVIEW ---------------------- --%>
    <% } else if ("reviews".equals(v)) { %>

        <h2 class="fw-bold mb-3">리뷰 미리보기</h2>

        <% if (!loggedIn) { %>
            <div class="alert alert-warning">
                리뷰는 로그인 후 이용 가능합니다.
                <a href="<%=loginForReview%>" class="btn btn-primary btn-sm ms-2">로그인</a>
            </div>
        <% } else { %>
            <div class="alert alert-info">리뷰 페이지에서 자세한 내용을 확인할 수 있습니다.</div>
        <% } %>

    <% } %>

    </div>

</div>
</body>
</html>
