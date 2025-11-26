<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="dto.User, dao.PostDAO, dto.Post, dao.PlaceReviewDAO, dao.MatchReviewDAO, java.util.*" %>

<%
    Object loginObj = session.getAttribute("loginUser");
    if (loginObj == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    User loginUser = (User) loginObj;
    String displayName = (loginUser.getName() != null && !loginUser.getName().isEmpty())
                         ? loginUser.getName()
                         : loginUser.getUsername();

    int loginUserId = loginUser.getId();
    String ctx = request.getContextPath();

    String fUsername = loginUser.getUsername();
    String fName = displayName;
    String fEmail = loginUser.getEmail();
    String fRole = loginUser.getRole();

    String fProfile = (loginUser.getProfileImage() != null && !loginUser.getProfileImage().isEmpty())
                       ? (ctx + "/uploads/" + loginUser.getProfileImage())
                       : (ctx + "/assets/img/1.png");

    List<Post> myPosts = new ArrayList<>();
    try (PostDAO dao = new PostDAO()) {
        myPosts = dao.listByAuthor(fUsername);
    } catch (Exception e) { e.printStackTrace(); }

    PlaceReviewDAO placeDAO = new PlaceReviewDAO();
    MatchReviewDAO matchDAO = new MatchReviewDAO();

    List<Map<String,Object>> myPlaceReviews = placeDAO.listByUser(loginUserId);
    List<Map<String,Object>> myMatchReviews = matchDAO.listByUser(loginUserId);

    int totalReviewCount = myPlaceReviews.size() + myMatchReviews.size();
%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8" />
<title>마이페이지</title>
<link rel="icon" href="<%=ctx%>/assets/favicon.ico" />
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

<!-- 🔥 커스텀 UI 스타일 -->
<style>
    body {
        background: #f3f6fb;
        font-family: "Pretendard", sans-serif;
    }

    .page-title {
        font-size: 32px;
        font-weight: 800;
        color: #1f2a44;
    }

    /* ⭐ 프로필 + 계정 정보 카드 높이를 동일하게 */
    .equal-card {
        height: 100%;
        display: flex;
        flex-direction: column;
        justify-content: center;   /* 세로 가운데 */
        border-radius: 16px;
        box-shadow: 0 8px 25px rgba(0,0,0,0.06);
        padding: 30px;
        background: #ffffff;
    }

    /* ⭐ 프로필 내부 요소를 완전 가운데 정렬 */
    .profile-wrapper {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;   /* 수직 가운데 */
        text-align: center;
        flex: 1;
    }

    .profile-img {
        width: 150px;
        height: 150px;
        border-radius: 50%;
        object-fit: cover;
        border: 5px solid #e3ebff;
        margin-bottom: 16px;
    }

    .section-title {
        font-size: 18px;
        font-weight: 700;
        color: #111827;
    }

    .item-card {
        border-radius: 12px;
        padding: 12px 15px;
        background: #ffffff;
        transition: 0.15s;
        border: 1px solid #e5e7eb;
    }

    .item-card:hover {
        background: #eef4ff;
        transform: translateY(-2px);
        box-shadow: 0 8px 20px rgba(0,0,0,0.12);
    }
</style>

</head>

<body class="d-flex flex-column min-vh-100">

<!-- 네비게이션 -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
  <div class="container-fluid px-5">
    <a class="navbar-brand fw-bold" href="<%=ctx%>/main.jsp">볼피또</a>

    <button class="navbar-toggler" data-bs-toggle="collapse" data-bs-target="#nav">
        <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse" id="nav">
      <ul class="navbar-nav ms-auto">
        <li class="nav-item"><span class="nav-link disabled"><%=displayName%>님</span></li>
        <li class="nav-item"><a class="nav-link" href="<%=ctx%>/main.jsp">홈</a></li>
        <li class="nav-item"><a class="nav-link active" href="<%=ctx%>/mypage.jsp">마이페이지</a></li>
        <li class="nav-item"><a class="nav-link" href="<%=ctx%>/logout.jsp">로그아웃</a></li>
      </ul>
    </div>
  </div>
</nav>



<main class="flex-grow-1">
<div class="container py-5">

<h1 class="page-title mb-4">
    <i class="bi bi-journal-text me-2"></i> 마이페이지
</h1>


    <!-- ⭐ 두 카드 높이 동일하게 & 정렬 개선 -->
    <div class="row g-4 align-items-stretch">

        <!-- 프로필 카드 -->
        <div class="col-md-4">
            <div class="equal-card">
                <div class="profile-wrapper">
                    <img src="<%=fProfile%>" class="profile-img">
                    <h4 class="fw-bold"><%=fName%></h4>
                    <small class="text-muted d-block">ID: <%=fUsername%></small>
                    <small class="text-muted">역할(Role): <%=fRole%></small>
                </div>
            </div>
        </div>

        <!-- 계정 정보 카드 -->
        <div class="col-md-8">
            <div class="equal-card">
                <h5 class="section-title mb-3">계정 정보</h5>

                <p class="mb-1"><b>이름:</b> <%=fName%></p>
                <p class="mb-1"><b>아이디:</b> <%=fUsername%></p>
                <p class="mb-3"><b>이메일:</b> <%=fEmail%></p>

                <div class="d-flex gap-2 mt-3">
                    <a href="<%=ctx%>/editProfile.jsp" class="btn btn-primary">프로필 수정</a>
                    <a href="<%=ctx%>/main.jsp" class="btn btn-outline-secondary">홈으로</a>
                    <a href="<%=ctx%>/logout.jsp" class="btn btn-outline-danger ms-auto">로그아웃</a>
                </div>
            </div>
        </div>

    </div>


    <!-- ⭐ 리뷰 영역 -->
    <div class="card card-custom mt-5">
        <div class="card-header bg-light fw-bold">
            ⭐ 내가 작성한 리뷰 (<%= totalReviewCount %>)
        </div>
        <div class="card-body">
        
        <% if (totalReviewCount == 0) { %>

            <p class="text-muted">작성한 리뷰가 없습니다.</p>

        <% } else { %>

            <!-- 장소 리뷰 -->
            <% if (!myPlaceReviews.isEmpty()) { %>
            <h6 class="fw-bold mt-2">📍 장소 리뷰</h6>

            <% for (var r : myPlaceReviews) { %>
            <div class="item-card mb-3">
                <b><%= r.get("place_name") %></b><br>
                <span class="text-warning">★</span> <%=r.get("rating")%><br>
                <small class="text-muted"><%=r.get("created_at")%></small>
                <p class="mt-2 mb-0"><%=r.get("content")%></p>
            </div>
            <% } %>
            <% } %>

            <!-- 경기 리뷰 -->
            <% if (!myMatchReviews.isEmpty()) { %>
            <h6 class="fw-bold mt-3 mb-2">⚽ 경기 리뷰</h6>

            <% for (var r : myMatchReviews) { %>
            <div class="item-card mb-3">
                <b>경기 ID: <%=r.get("match_id")%></b><br>
                <span class="text-warning">★</span> <%=r.get("rating")%><br>
                <small class="text-muted"><%=r.get("created_at")%></small>
                <p class="mt-2 mb-0"><%=r.get("content")%></p>
            </div>
            <% } %>
            <% } %>

        <% } %>

        </div>
    </div>


    <!-- ⭐ 게시글 영역 -->
    <div class="card card-custom mt-5 mb-5">
        <div class="card-header bg-light fw-bold">
            📄 내가 작성한 게시글 (<%= myPosts.size() %>)
        </div>

        <div class="card-body">

        <% if (myPosts.isEmpty()) { %>
            <p class="text-muted">작성한 게시글이 없습니다.</p>
        <% } else { %>

            <% for (Post p : myPosts) { %>
            <div class="item-card mb-3">

                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <a href="<%=ctx%>/post.jsp?id=<%=p.getId()%>&from=mypage"
                           class="fw-semibold text-decoration-none text-dark">
                           <%= p.getTitle() %>
                        </a>
                        <div class="text-muted small mt-1">
                            <%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(p.getCreatedAt()) %>
                        </div>
                    </div>

                    <div class="d-flex gap-2">
                        <a href="<%=ctx%>/edit.jsp?id=<%=p.getId()%>&from=mypage"
                           class="btn btn-sm btn-outline-primary">수정</a>

                        <form action="<%=ctx%>/deletePost" method="post"
                              onsubmit="return confirm('정말 삭제하시겠습니까?');">
                                <input type="hidden" name="postId" value="<%=p.getId()%>">
                                <button type="submit" class="btn btn-sm btn-outline-danger">삭제</button>
                        </form>
                    </div>

                </div>

            </div>
            <% } %>

        <% } %>

        </div>
    </div>


</div>
</main>


<footer class="mt-auto py-4 bg-dark text-light">
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


<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html
