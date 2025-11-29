<%@ page contentType="text/html; charset=UTF-8" language="java" pageEncoding="UTF-8" session="true" %>
<%@ page import="java.util.*, java.net.URLEncoder" %>
<%@ page import="dao.MatchDAO, dto.Match" %>
<%@ page import="dao.PostDAO, dto.Post" %>

<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    Object userObj = session.getAttribute("loginUser");
    String username = (String) session.getAttribute("username");
    boolean loggedIn = (userObj != null) || (username != null);

    MatchDAO MatchDAO = new MatchDAO();
    List<Match> matchList = MatchDAO.getTodayMatches();
    if (matchList.size() > 5) matchList = matchList.subList(0, 5);

    java.time.LocalDate today = java.time.LocalDate.now();
    String todayStr = today.format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd (E)"));

    String v = request.getParameter("v");
    if (v == null) v = "matches";

    String btnMatches = v.equals("matches") ? "active-tab" : "";
    String btnComm = v.equals("community") ? "active-tab" : "";
    String btnReview = v.equals("reviews") ? "active-tab" : "";

    List<Post> previewPosts;
    try (PostDAO pdao = new PostDAO()) {
        previewPosts = pdao.list("전체");
    }
    if (previewPosts == null) previewPosts = new ArrayList<>();
    if (previewPosts.size() > 4) previewPosts = previewPosts.subList(0, 4);

    String loginForReview = ctx + "/login.jsp?redirect=" + URLEncoder.encode("reviews.jsp", "UTF-8");
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="utf-8" />
    <title>볼피또</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

    <link href="<%=ctx%>/css/styles.css" rel="stylesheet" />

    <style>
        body {
            background: #F5F7FA;
            font-family: 'Pretendard','Noto Sans KR',sans-serif;
        }
        .hero-section {
            background: linear-gradient(135deg, #2BAE66 0%, #1C7C44 100%);
            border-radius: 18px;
            padding: 55px;
            color: white;
            display: flex;
            align-items: center;
            margin-top: 35px;
            margin-bottom: 60px;
        }
        .hero-text h1 {
            font-size: 42px;
            font-weight: 800;
        }
        .hero-text p {
            font-size: 18px;
            margin-bottom: 20px;
            opacity: .9;
        }
        .hero-img img {
            width: 100%;
            border-radius: 16px;
            box-shadow: 0 8px 20px rgba(0,0,0,0.18);
        }

        /* 기능 카드 */
        .feature-card {
            border-radius: 16px;
            padding: 28px 20px;
            background: white;
            box-shadow: 0 5px 15px rgba(0,0,0,0.08);
            transition: .2s;
        }
        .feature-card:hover {
            transform: translateY(-4px);
        }
        .feature-card i {
            font-size: 38px;
            color: #2BAE66;
            margin-bottom: 10px;
        }
        .feature-card h4 {
            font-weight: 700;
            margin-bottom: 10px;
        }

        /* preview 섹션 */
        .tab-menu {
            display: flex;
            gap: 20px;
            margin-bottom: 20px;
        }
        .tab-menu a {
            padding: 10px 22px;
            border-radius: 30px;
            background: #E9ECEF;
            color: #333;
            font-weight: 600;
            text-decoration: none;
        }
        .tab-menu .active-tab {
            background: #2BAE66;
            color: white !important;
        }

        .preview-box {
            background: white;
            padding: 25px;
            border-radius: 16px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.07);
        }
    </style>
</head>

<body>

<!-- NAV -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark py-3">
    <div class="container px-5">
        <a class="navbar-brand fw-bold" href="<%=ctx%>/index.jsp">볼피또</a>
        <ul class="navbar-nav ms-auto">
            <li class="nav-item"><a class="nav-link active" href="<%=ctx%>/index.jsp">Home</a></li>
            <li class="nav-item"><a class="nav-link" href="<%=ctx%>/login.jsp">로그인</a></li>
            <li class="nav-item"><a class="nav-link" href="<%=ctx%>/register.jsp">회원가입</a></li>
        </ul>
    </div>
</nav>

<!-- HERO -->
<div class="container">
    <div class="hero-section row">
        <div class="col-lg-5 hero-text">
            <h1>함께하는 축구 · 풋살 플랫폼</h1>
            <p>근처에서 빠르게 경기 매칭, 팀원 모집, 커뮤니티까지!</p>
            <a href="<%=ctx%>/register.jsp" class="btn btn-light btn-lg fw-bold text-success">지금 시작하기</a>
        </div>
        <div class="col-lg-7 hero-img">
            <img src="<%=ctx%>/assets/img/football.png">
        </div>
    </div>
</div>

<!-- 기능 카드 -->
<div class="container mb-5">
    <div class="row text-center">

        <div class="col-md-4 mb-3">
            <div class="feature-card">
                <i class="bi bi-people"></i>
                <h4>경기 매칭</h4>
                <p class="text-muted mb-3">원하는 시간·지역에서 팀원을 찾아보세요.</p>
                <a href="<%=ctx%>/index.jsp?v=matches#preview" class="btn btn-outline-success">보러가기</a>
            </div>
        </div>

        <div class="col-md-4 mb-3">
            <div class="feature-card">
                <i class="bi bi-chat-dots"></i>
                <h4>커뮤니티</h4>
                <p class="text-muted mb-3">자유로운 정보 공유와 팀원 소통 공간.</p>
                <a href="<%=ctx%>/index.jsp?v=community#preview" class="btn btn-outline-success">보러가기</a>
            </div>
        </div>

        <div class="col-md-4 mb-3">
            <div class="feature-card">
                <i class="bi bi-star"></i>
                <h4>리뷰</h4>
                <p class="text-muted mb-3">참여한 경기의 리뷰를 남겨보세요.</p>
                <a href="<%=ctx%>/index.jsp?v=reviews#preview" class="btn btn-outline-success">보러가기</a>
            </div>
        </div>

    </div>
</div>

<!-- PREVIEW -->
<div class="container mb-5" id="preview">

    <div class="tab-menu mb-3">
        <a href="<%=ctx%>/index.jsp?v=matches#preview" class="<%=btnMatches%>">경기 매칭</a>
        <a href="<%=ctx%>/index.jsp?v=community#preview" class="<%=btnComm%>">커뮤니티</a>
        <a href="<%=ctx%>/index.jsp?v=reviews#preview" class="<%=btnReview%>">리뷰</a>
    </div>

    <div class="preview-box">

        <% if ("matches".equals(v)) { %>
            <h3 class="fw-bold mb-2">오늘의 경기 현황</h3>
            <p class="text-muted mb-3"><%=todayStr%></p>

            <% if (matchList.isEmpty()) { %>
                <div class="alert alert-info">오늘 등록된 경기가 없습니다.</div>
            <% } else { %>
                <ul class="list-group">
                <% for (Match m : matchList) { %>
                    <li class="list-group-item d-flex justify-content-between">
                        <div>
                            <strong><%=m.getMatchTime()%> 경기</strong><br>
                            <small class="text-muted"><%=m.getLocation()%> · <%=m.getCurrentPlayers()%>/<%=m.getMaxPlayers()%></small>
                        </div>
                        <span class="badge bg-success">예약중</span>
                    </li>
                <% } %>
                </ul>
            <% } %>

        <% } else if ("community".equals(v)) { %>

            <h3 class="fw-bold mb-3">커뮤니티 최신글</h3>

            <% if (previewPosts.isEmpty()) { %>
                <div class="alert alert-info">게시글이 없습니다.</div>
            <% } else { %>
                <ul class="list-group">
                    <% java.text.SimpleDateFormat df = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm"); %>
                    <% for (Post p : previewPosts) { %>
                        <li class="list-group-item d-flex justify-content-between">
                            <span>
                                <%= p.getTitle() %>
                                <small class="text-muted"> · <%= p.getAuthor() %> · <%= df.format(p.getCreatedAt()) %></small>
                            </span>
                            <a href="<%=ctx%>/login.jsp" class="btn btn-sm btn-outline-secondary">보기</a>
                        </li>
                    <% } %>
                </ul>
            <% } %>

        <% } else if ("reviews".equals(v)) { %>

            <h3 class="fw-bold mb-3">리뷰 미리보기</h3>

            <% if (!loggedIn) { %>
                <div class="alert alert-warning">
                    리뷰는 로그인 후 이용 가능합니다.
                    <a href="<%=loginForReview%>" class="btn btn-success btn-sm ms-2">로그인</a>
                </div>
            <% } else { %>
                <div class="alert alert-info">리뷰 페이지에서 상세 리뷰를 확인하세요.</div>
            <% } %>

        <% } %>

    </div>
</div>

</body>
</html>