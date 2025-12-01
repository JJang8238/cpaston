<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="dto.User, dao.MatchDAO, dto.Match, java.util.*, java.time.*" %>

<%
    // 로그인 체크
    Object obj = session.getAttribute("loginUser");
    if (obj == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
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

    <style>
        /* 전체 페이지 기본 값 : 로그인 화면이랑 동일하게 */
        html, body {
            margin: 0;
            padding: 0;
            height: 100%;
            background: #f3f5f7;   /* 연회색 (로그인 배경색) */
        }

        /* 페이지 전체를 감싸는 래퍼 (footer를 아래로 밀기용) */
        .page-wrap {
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        /* 네비 아래 실제 컨텐츠 영역 */
        .content-wrap {
            flex: 1;                 /* footer 제외하고 남은 영역 채우기 */
            padding-top: 40px;
            padding-bottom: 40px;
        }

        /* Hero Green Box */
        .hero-box {
            background: #2E8F4D;
            border-radius: 20px;
            padding: 55px 50px;
            margin-top: 10px;
        }
        .hero-title {
            font-size: 2.4rem;
            font-weight: bold;
            color: white;
        }
        .hero-sub {
            color: rgba(255,255,255,0.85);
            font-size: 1.1rem;
        }
        .hero-btn {
            background: white;
            color: #2E8F4D;
            font-weight: 700;
            padding: 12px 23px;
            border-radius: 8px;
        }

        /* 공지 박스 */
        .notice-box {
            margin-top: 40px;
            margin-bottom: 40px;
            background: #6c757d;
            color: white;
            padding: 15px;
            border-radius: 10px;
        }

        /* 서비스 카드 */
        .service-card {
            background: white;
            border-radius: 15px;
            padding: 35px;
            box-shadow: 0px 3px 10px rgba(0,0,0,0.08);
        }

        /* footer */
        footer {
            background: #212529;
            padding: 40px 0;
            color: white;
        }
    </style>
</head>

<body>
<div class="page-wrap"><!-- 전체 래퍼 시작 -->

    <!-- 네비게이션 (기능 그대로) -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container px-5">
            <a class="navbar-brand" href="<%=ctx%>/main.jsp">볼피또</a>
            <ul class="navbar-nav ms-auto">
                <li class="nav-item"><span class="nav-link disabled"><%=displayName%>님 환영합니다</span></li>
                <li class="nav-item"><a class="nav-link" href="<%=ctx%>/mypage.jsp">마이페이지</a></li>
                <li class="nav-item"><a class="nav-link" href="<%=ctx%>/logout.jsp">로그아웃</a></li>
                <li class="nav-item"><a class="nav-link" href="<%=ctx%>/admin/admin_menu.jsp">관리자페이지</a></li>
            </ul>
        </div>
    </nav>

    <!-- 실제 내용 -->
    <div class="content-wrap">
        <div class="container px-4 px-lg-5">

            <!-- Hero -->
            <div class="hero-box row align-items-center shadow">
                <div class="col-lg-6 mb-4 mb-lg-0">
                    <h1 class="hero-title"><%=displayName%>님, 환영합니다!</h1>
                    <p class="hero-sub">오늘도 가까운 지역에서 경기를 즐겨보세요.</p>
                    <a class="btn hero-btn" href="<%=ctx%>/sports.jsp">지금 참여하기</a>
                </div>
                <div class="col-lg-6 text-center">
                    <img src="<%=ctx%>/assets/img/football.png" class="img-fluid rounded" style="border-radius:15px;">
                </div>
            </div>

            <!-- 공지 -->
            <div class="notice-box text-center">
                심한 욕설, 불법 행위 등을 금지합니다.
            </div>

            <!-- 서비스 카드 -->
            <div class="row text-center mb-5">
                <div class="col-md-4 mb-4">
                    <div class="service-card">
                        <h3>경기 매칭</h3>
                        <p class="text-muted">원하는 시간·지역에서 팀원을 찾아보세요.</p>
                        <a class="btn btn-outline-success" href="<%=ctx%>/sports.jsp">보러가기</a>
                    </div>
                </div>

                <div class="col-md-4 mb-4">
                    <div class="service-card">
                        <h3>커뮤니티</h3>
                        <p class="text-muted">자유롭게 정보 공유와 팀원 소통 공간.</p>
                        <a class="btn btn-outline-success" href="<%=ctx%>/community.jsp">보러가기</a>
                    </div>
                </div>

                <div class="col-md-4 mb-4">
                    <div class="service-card">
                        <h3>리뷰</h3>
                        <p class="text-muted">참여한 경기를 평가해보세요.</p>
                        <a class="btn btn-outline-success" href="<%=ctx%>/review.jsp">보러가기</a>
                    </div>
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
                        String timeStr = (m.getMatchTime() != null)
                                         ? m.getMatchTime().toString()
                                         : "시간 없음";

                        String place = m.getLocation();
                        int cur = m.getCurrentPlayers();
                        int max = m.getMaxPlayers();
                        String status = m.getMatchStatus();

                        String badgeText = "";
                        String badgeColor = "";

                        if ("취소됨".equals(status)) {
                            badgeText = "경기 취소";
                            badgeColor = "danger";
                        } else if (cur >= max) {
                            badgeText = "예약 마감";
                            badgeColor = "secondary";
                        } else {
                            badgeText = "예약중";
                            badgeColor = "success";
                        }
            %>
                <a href="#" class="list-group-item list-group-item-action d-flex justify-content-between align-items-center">
                    <div>
                        <div class="h6 mb-1"><%=timeStr%> 경기</div>
                        <small class="text-muted"><%=place%> | 인원: <%=cur%> / <%=max%></small>
                    </div>
                    <span class="badge bg-<%=badgeColor%> rounded-pill px-3 py-2"><%=badgeText%></span>
                </a>
            <%
                    }
                }
            %>
            </div>

        </div>
    </div>

    <!-- Footer -->
    <footer>
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

</div><!-- page-wrap 끝 -->

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>


