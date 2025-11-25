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
    <title>메인 페이지</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>

<!-- ⭐ footer를 항상 아래로 내리는 핵심 구조 ⭐ -->
<body class="d-flex flex-column min-vh-100 bg-light">

<!-- 네비게이션 -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container px-5">
        <a class="navbar-brand" href="<%=ctx%>/main.jsp">볼피또</a>
        <ul class="navbar-nav ms-auto">
            <li class="nav-item"><span class="nav-link disabled"><%=displayName%>님 환영합니다</span></li>
            <li class="nav-item"><a class="nav-link" href="<%=ctx%>/mypage.jsp">마이페이지</a></li>
            <li class="nav-item"><a class="nav-link" href="<%=ctx%>/logout.jsp">로그아웃</a></li>
        </ul>
    </div>
</nav>

<!-- ⭐ 콘텐츠 영역 (footer 위 공간 전체 차지) ⭐ -->
<main class="flex-grow-1">
<div class="container px-4 px-lg-5">

    <!-- Hero -->
    <div class="row gx-4 gx-lg-5 align-items-center my-5">
        <div class="col-lg-7">
            <img class="img-fluid rounded" src="<%=ctx%>/assets/img/football.png" />
        </div>
        <div class="col-lg-5">
            <h1 class="fw-bold">우리의 운동 플랫폼</h1>
            <p class="text-muted">원하는 지역에서 경기를 즐겨보세요.</p>
            <a class="btn btn-primary" href="<%=ctx%>/sports.jsp">지금 참여하기</a>
        </div>
    </div>

    <!-- 공지 -->
    <div class="my-5 p-3 bg-secondary text-white text-center rounded">
        심한 욕설, 불법 행위 등을 금지합니다.
    </div>

    <!-- 서비스 카드 -->
    <div class="row text-center mb-5">
        <div class="col-md-4">
            <div class="card shadow-sm"><div class="card-body">
                <h3>경기 매칭</h3>
                <p class="text-muted">원하는 지역에서 경기를 즐길 수 있습니다.</p>
                <a class="btn btn-primary" href="<%=ctx%>/sports.jsp">자세히보기</a>
            </div></div>
        </div>

        <div class="col-md-4 mt-4 mt-md-0">
            <div class="card shadow-sm"><div class="card-body">
                <h3>커뮤니티</h3>
                <p class="text-muted">자유롭게 대화를 나눠보세요.</p>
                <a class="btn btn-outline-primary" href="<%=ctx%>/community.jsp">자세히보기</a>
            </div></div>
        </div>

        <div class="col-md-4 mt-4 mt-md-0">
            <div class="card shadow-sm"><div class="card-body">
                <h3>리뷰</h3>
                <p class="text-muted">참여한 경기를 평가하세요.</p>
                <a class="btn btn-outline-primary" href="<%=ctx%>/review.jsp">자세히보기</a>
            </div></div>
        </div>
    </div>

    <!-- 오늘의 경기 예약 현황 -->
    <h2 class="fw-bold mb-1">오늘의 경기 예약 현황</h2>
    <div class="text-muted mb-3"><%=today.toString()%></div>

    <div class="list-group shadow-sm mb-5">

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

        <a href="#" class="list-group-item list-group-item-action d-flex justify-content-between align-items-center">
            <div>
                <div class="h6 mb-1"><%=m.getMatchTime()%> 경기</div>
                <small class="text-muted"><%=m.getLocation()%> | 인원: <%=m.getCurrentPlayers()%> / <%=m.getMaxPlayers()%></small>
            </div>
            <span class="badge bg-success rounded-pill px-3 py-2">예약중</span>
        </a>

    <%
            }
        }
    %>

    </div>

</div>
</main>

<!-- ⭐ footer — 항상 화면 맨 아래 ⭐ -->
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
