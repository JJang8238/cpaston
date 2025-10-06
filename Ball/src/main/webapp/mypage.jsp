<%@ page contentType="text/html; charset=UTF-8" session="true" %>
<%@ page import="dto.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>볼피또 - 마이페이지</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

    <!-- 헤더 -->
    <header class="site-header bg-dark text-white">
        <div class="container d-flex justify-content-between align-items-center py-3">
            <h1 class="logo fw-bold mb-0">볼피또</h1>
            <nav class="nav">
                <a href="<%=ctx%>/index.jsp" class="nav-link text-white">홈</a>
                <a href="<%=ctx%>/community.jsp" class="nav-link text-white">커뮤니티</a>
                <a href="<%=ctx%>/logout.jsp" class="nav-link text-white">로그아웃</a>
            </nav>
        </div>
    </header>

    <!-- 메인 -->
    <main class="container my-5">
        <div class="card shadow-sm p-4">
            <h2 class="text-primary text-center mb-4"><%= user.getName() %> 님의 마이페이지</h2>
            <hr>

            <!-- 예약 관리 -->
            <section class="mb-4">
                <h3 class="border-start border-primary ps-3 mb-3 fw-bold">예약 관리</h3>
                <ul class="list-unstyled ms-3">
                    <li><a href="reservationList.jsp" class="text-decoration-none text-primary">예약 현황 확인</a></li>
                    <li><a href="reservationHistory.jsp" class="text-decoration-none text-primary">지난 예약 내역 조회</a></li>
                    <li><a href="reservationChange.jsp" class="text-decoration-none text-primary">예약 변경 및 취소</a></li>
                </ul>
            </section>

            <!-- 회원 정보 관리 -->
            <section class="mb-4">
                <h3 class="border-start border-primary ps-3 mb-3 fw-bold">회원 정보 관리</h3>
                <ul class="list-unstyled ms-3">
                    <li><a href="editProfile.jsp" class="text-decoration-none text-primary">개인 정보 수정</a></li>
                    <li><a href="changePassword.jsp" class="text-decoration-none text-primary">비밀번호 변경</a></li>
                    <li><a href="deleteAccount.jsp" class="text-decoration-none text-primary">회원 탈퇴</a></li>
                </ul>
            </section>

            <!-- 부가 기능 -->
            <section class="mb-4">
                <h3 class="border-start border-primary ps-3 mb-3 fw-bold">부가 기능</h3>
                <ul class="list-unstyled ms-3">
                    <li><a href="notifications.jsp" class="text-decoration-none text-primary">알림 및 메시지</a></li>
                    <li><a href="favorites.jsp" class="text-decoration-none text-primary">단골 운동장 설정</a></li>
                    <li><a href="reviews.jsp" class="text-decoration-none text-primary">시설 이용 후기</a></li>
                    <li><a href="payments.jsp" class="text-decoration-none text-primary">결제 내역 관리</a></li>
                </ul>
            </section>

            <!-- 커뮤니티 기능 -->
            <section>
                <h3 class="border-start border-primary ps-3 mb-3 fw-bold">커뮤니티 기능</h3>
                <ul class="list-unstyled ms-3">
                    <li><a href="myPosts.jsp" class="text-decoration-none text-primary">내 글 목록</a></li>
                    <li><a href="inviteTeam.jsp" class="text-decoration-none text-primary">팀원 초대</a></li>
                </ul>
            </section>
        </div>
    </main>

    <!-- 푸터 -->
      <footer class="site-footer">
    	<div class="container text-center">
      		<small>Copyright © 플랩풋볼 <%= java.time.Year.now() %></small>
    	</div>
  	 </footer>
</body>
</html>
