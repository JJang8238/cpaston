<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="dto.User, dao.MatchDAO, dto.Match, java.util.*, java.time.*" %>

<%
    // 로그인 체크
    Object obj = session.getAttribute("loginUser");
    if (obj == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    User loginUser = (obj instanceof User) ? (User) obj : null;
    String displayName = (loginUser != null && loginUser.getName() != null)
                        ? loginUser.getName()
                        : String.valueOf(obj);

    String ctx = request.getContextPath();

    // 오늘 날짜
    LocalDate today = LocalDate.now();

    // DB에서 오늘 경기 불러오기
    MatchDAO mdao = new MatchDAO();
    List<Match> matches = mdao.getTodayMatches();
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>볼피또 – 메인</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

    <style>
        body {
            background: #F4F6F9;
            font-family: 'Pretendard','Noto Sans KR',sans-serif;
        }

        /* HERO */
        .hero-section {
            background: linear-gradient(135deg, #2BAE66 0%, #1C7C44 100%);
            border-radius: 18px;
            padding: 55px;
            color: white;
            display: flex;
            align-items: center;
            margin-top: 35px;
            margin-bottom: 50px;
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
        .feature-card:hover { transform: translateY(-4px); }
        .feature-card i {
            font-size: 38px;
            color: #2BAE66;
            margin-bottom: 10px;
        }

        /* PREVIEW BOX */
        .preview-box {
            background: white;
            padding: 25px;
            border-radius: 16px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.07);
        }
    </style>
</head>

<body class="d-flex flex-column min-vh-100 bg-light">

<!-- 네비게이션 -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark py-3">
    <div class="container px-5">
        <a class="navbar-brand fw-bold" href="<%=ctx%>/main.jsp">볼피또</a>
        <ul class="navbar-nav ms-auto">
            <li class="nav-item"><span class="nav-link disabled"><%=displayName%>님 환영합니다</span></li>
            <li class="nav-item"><a class="nav-link" href="<%=ctx%>/mypage.jsp">마이페이지</a></li>
            <li class="nav-item"><a class="nav-link" href="<%=ctx%>/logout.jsp">로그아웃</a></li>
        </ul>
    </div>
</nav>

<main class="flex-grow-1">
<div class="container px-4 px-lg-5">

    <!-- HERO -->
    <div class="hero-section row">
        <div class="col-lg-5 hero-text">
            <h1>함께하는 축구 · 풋살 플랫폼</h1>
            <p>근처에서 빠르게 경기 매칭, 팀원 모집, 커뮤니티까지!</p>
            <a href="<%=ctx%>/sports.jsp" class="btn btn-light btn-lg fw-bold text-success">지금 참여하기</a>
        </div>
        <div class="col-lg-7 hero-img">
            <img src="<%=ctx%>/assets/img/football.png">
        </div>
    </div>

    <!-- 기능 카드 -->
    <div class="row text-center mb-5">
        <div class="col-md-4 mb-3">
            <div class="feature-card">
                <i class="bi bi-people"></i>
                <h4>경기 매칭</h4>
                <p class="text-muted">원하는 시간·지역에서 팀원을 찾아보세요.</p>
                <a href="<%=ctx%>/sports.jsp" class="btn btn-outline-success">보러가기</a>
            </div>
        </div>

        <div class="col-md-4 mb-3">
            <div class="feature-card">
                <i class="bi bi-chat-dots"></i>
                <h4>커뮤니티</h4>
                <p class="text-muted">소통하고 정보를 나눠보세요.</p>
                <a href="<%=ctx%>/community.jsp" class="btn btn-outline-success">보러가기</a>
            </div>
        </div>

        <div class="col-md-4 mb-3">
            <div class="feature-card">
                <i class="bi bi-star"></i>
                <h4>리뷰</h4>
                <p class="text-muted">참여한 경기를 평가하세요.</p>
                <a href="<%=ctx%>/review.jsp" class="btn btn-outline-success">보러가기</a>
            </div>
        </div>
    </div>

    <!-- 오늘의 경기 현황 -->
    <div class="preview-box mb-5">

        <h3 class="fw-bold mb-2">오늘의 경기 현황</h3>
        <p class="text-muted mb-3"><%=today.toString()%></p>

        <div class="list-group">

        <%
            if (matches == null || matches.isEmpty()) {
        %>
            <div class="list-group-item text-center text-muted">
                오늘 예정된 경기가 없습니다.
            </div>

        <%
            } else {
                for (Match m : matches) {
        %>

            <div class="list-group-item d-flex justify-content-between align-items-center">
                <div>
                    <div class="h6 mb-1"><%=m.getMatchTime()%> 경기</div>
                    <small class="text-muted"><%=m.getLocation()%> | 인원: <%=m.getCurrentPlayers()%> / <%=m.getMaxPlayers()%></small>
                </div>
                <span class="badge bg-success rounded-pill px-3 py-2">예약중</span>
            </div>

        <%
                }
            }
        %>
        </div>

    </div>

</div>
</main>

<!-- footer -->
<footer class="py-4 bg-dark text-light mt-auto">
  <div class="container text-center">
      <div class="mb-1" style="font-size: 20px; font-weight: 700;">
          ⚽ Ballpitto – Play Together, Enjoy More
      </div>

      <div class="small text-secondary">
          📍 위치 기반 경기 매칭&nbsp;&nbsp;|&nbsp;&nbsp;
          👥 파트너 찾기&nbsp;&nbsp;|&nbsp;&nbsp;
          📝 리뷰 & 커뮤니티
      </div>
  </div>
</footer>

</body>
</html>
