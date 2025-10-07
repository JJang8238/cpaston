<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
    <%@ page import="dto.User" %>
        <% User loginUser=(User) session.getAttribute("loginUser"); if (loginUser==null) {
            response.sendRedirect("index.jsp"); return; } %>
            <!DOCTYPE html>
            <html lang="ko">

            <head>
                <meta charset="UTF-8">
                <title>메인 페이지123</title>
                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
            </head>

            <body>

                <!-- 상단 네비게이션 -->
                <nav class="navbar navbar-expand-lg navbar-dark bg-dark px-3">
                    <div class="d-flex w-100 justify-content-between align-items-center">
                        <div class="text-white fw-bold">
                            <%= loginUser.getName() %>님 환영합니다.
                        </div>
                        <div>
                            <a href="index.jsp" class="btn btn-link text-white">홈</a>
                            <a href="mypage.jsp" class="btn btn-link text-white">마이페이지</a>
                            <a href="logout.jsp" class="btn btn-link text-white">로그아웃</a>
                        </div>
                    </div>
                </nav>

                <!-- 메인 컨텐츠 -->
                <div class="container px-4 px-lg-5">
                    <!-- Heading Row -->
                    <div class="row gx-4 gx-lg-5 align-items-center my-5">
                        <div class="col-lg-7">
                            <img class="img-fluid rounded mb-4 mb-lg-0"
                                src="<%=request.getContextPath()%>/assets/image/football.png" alt="플랩풋볼 메인 이미지" />
                        </div>
                        <div class="col-lg-5">
                            <h1 class="font-weight-light">우리의 운동 플랫폼</h1>
                            <p>이 사이트는 경기 매칭, 커뮤니티, 리뷰 기능을 모두 제공합니다.</p>
                            <!-- sports.jsp로 이동 -->
                            <a class="btn btn-primary" href="<%=request.getContextPath()%>/sports.jsp">지금 참여하기</a>
                        </div>
                    </div>

                    <div class="my-5 p-3 bg-secondary text-white text-center rounded">
                        심한 욕설, 불법 행위 등을 금지합니다.
                    </div>

                    <div class="row text-center">
                        <div class="col-md-4">
                            <div class="card mb-3">
                                <div class="card-body">
                                    <h3>경기 매칭</h3>
                                    <p>경기를 뛰고 싶을 때! 원하는 지역에서 매칭을 손쉽게!</p>
                                    <!-- sports.jsp로 이동 -->
                                    <a href="<%=request.getContextPath()%>/sports.jsp" class="btn btn-primary">자세히
                                        보기</a>
                                </div>
                            </div>
                        </div>

                        <div class="col-md-4">
                            <div class="card mb-3">
                                <div class="card-body">
                                    <h3>커뮤니티</h3>
                                    <p>같은 관심사를 가진 사람들과 소통 또는 모임을 만들어요.</p>
                                    <a href="<%=request.getContextPath()%>/sports.jsp" class="btn btn-primary">자세히
                                        보기</a>
                                </div>
                            </div>
                        </div>

                        <div class="col-md-4">
                            <div class="card mb-3">
                                <div class="card-body">
                                    <h3>리뷰</h3>
                                    <p>참여했던 경기, 모임에 대해 자유롭게 리뷰하고 평가할 수 있어요.</p>
                                    <a href="<%=request.getContextPath()%>/sports.jsp" class="btn btn-primary">자세히
                                        보기</a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

            </body>

            </html>