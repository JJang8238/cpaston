<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="dto.User, dao.PostDAO, dto.Post, dao.PlaceReviewDAO, dao.MatchReviewDAO, java.util.*" %>

<%
    /* --------------------------- 로그인 체크 --------------------------- */
    Object loginObj = session.getAttribute("loginUser");
    if (loginObj == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    User loginUser = null;
    String displayName = null;

    if (loginObj instanceof User) {
        loginUser = (User) loginObj;
        displayName = (loginUser.getName() != null && !loginUser.getName().isEmpty())
                        ? loginUser.getName()
                        : loginUser.getUsername();
    } else {
        displayName = String.valueOf(loginObj);
    }

    int loginUserId = loginUser.getId();
    String ctx = request.getContextPath();

    /* --------------------------- 프로필 정보 --------------------------- */
    String fUsername = loginUser.getUsername();
    String fName     = displayName;
    String fEmail    = loginUser.getEmail();
    String fRole     = loginUser.getRole();
    String fProfile  = (loginUser.getProfileImage() != null && !loginUser.getProfileImage().isEmpty())
                        ? loginUser.getProfileImage()
                        : ctx + "/assets/img/profile-default.png";

    /* --------------------------- 내가 쓴 게시글 --------------------------- */
    List<Post> myPosts = new ArrayList<>();
    try (PostDAO dao = new PostDAO()) {
        myPosts = dao.listByAuthor(fUsername);
    } catch (Exception e) { e.printStackTrace(); }

    /* --------------------------- 내가 쓴 리뷰 --------------------------- */
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
</head>

<body class="d-flex flex-column min-vh-100">

<!-- --------------------------- 네비 --------------------------- -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
  <div class="container px-5">
    <a class="navbar-brand" href="<%=ctx%>/main.jsp">볼피또</a>
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
<div class="container py-5 px-4 px-lg-5">

    <h1 class="fw-bold mb-4">마이페이지</h1>

    <div class="row g-4">

        <!-- -------------------- 프로필 카드 -------------------- -->
        <div class="col-md-4">
            <div class="card shadow-sm text-center">
                <div class="card-body">
                    <img src="<%=fProfile%>" class="rounded-circle mb-3"
                         style="width:140px;height:140px;object-fit:cover;">
                    <h4 class="fw-bold"><%=fName%></h4>
                    <p class="text-muted mb-0"><small>역할(Role): <%=fRole%></small></p>
                </div>
            </div>
        </div>

        <!-- -------------------- 계정 정보 카드 -------------------- -->
        <div class="col-md-8">
            <div class="card shadow-sm">
              <div class="card-body">
                <h5 class="mb-3">계정 정보</h5>

                <div class="mb-2">
                  <span class="text-muted">아이디(Username)</span>
                  <div class="fw-semibold"><%=fUsername%></div>
                </div>

                <div class="mb-2">
                  <span class="text-muted">이름(Name)</span>
                  <div class="fw-semibold"><%=fName%></div>
                </div>

                <div class="mb-2">
                  <span class="text-muted">이메일(Email)</span>
                  <div class="fw-semibold"><%=fEmail%></div>
                </div>

                <div class="d-flex gap-2 mt-4">
                  <a href="<%=ctx%>/editProfile.jsp" class="btn btn-primary">프로필 수정</a>
                  <a href="<%=ctx%>/main.jsp" class="btn btn-outline-secondary">홈으로</a>
                  <a href="<%=ctx%>/logout.jsp" class="btn btn-outline-danger ms-auto">로그아웃</a>
                </div>
              </div>
            </div>
        </div>

    </div>



    <!-- --------------------------- 내가 쓴 리뷰 --------------------------- -->
    <div class="card shadow-sm mt-5">
        <div class="card-header bg-light">
            <b>⭐ 내가 작성한 리뷰 (<%= totalReviewCount %>)</b>
        </div>

        <div class="card-body">

        <% if (totalReviewCount == 0) { %>

            <p class="text-muted mb-0">작성한 리뷰가 없습니다.</p>

        <% } else { %>


            <!-- 장소 리뷰 -->
            <% if (!myPlaceReviews.isEmpty()) { %>
                <h6 class="fw-bold mt-3">📍 장소 리뷰</h6>

                <ul class="list-group mb-3">
                <% for (var r : myPlaceReviews) { %>
                    <li class="list-group-item">
                        <div class="d-flex justify-content-between">
                            <div>
                                <strong><%= r.get("place_name") %></strong><br>

                                <span style="color:#FFC107;">
                                    <%= "★".repeat(Integer.parseInt(String.valueOf(r.get("rating")))) %>
                                </span>
                                <span class="text-muted small">(<%=r.get("rating")%>)</span><br>

                                <small class="text-muted"><%=r.get("created_at")%></small><br>
                                <span><%=r.get("content")%></span>
                            </div>

                            <div class="text-end">
                                <a href="<%=ctx%>/sports.jsp?place=<%=r.get("place_name")%>"
                                   class="btn btn-sm btn-outline-primary mt-2">
                                    보기
                                </a>
                            </div>
                        </div>
                    </li>
                <% } %>
                </ul>
            <% } %>


            <!-- 경기 리뷰 -->
            <% if (!myMatchReviews.isEmpty()) { %>
                <h6 class="fw-bold mt-3">⚽ 경기 리뷰</h6>

                <ul class="list-group">
                <% for (var r : myMatchReviews) { %>
                    <li class="list-group-item">
                        <div class="d-flex justify-content-between">
                            <div>
                                <strong>경기 ID: <%=r.get("match_id")%></strong><br>

                                <span style="color:#FFC107;">
                                    <%= "★".repeat(Integer.parseInt(String.valueOf(r.get("rating")))) %>
                                </span>
                                <span class="text-muted small">(<%=r.get("rating")%>)</span><br>

                                <small class="text-muted"><%=r.get("created_at")%></small><br>
                                <span><%=r.get("content")%></span>
                            </div>

                            <div class="text-end">
                                <a href="<%=ctx%>/sports.jsp"
                                   class="btn btn-sm btn-outline-primary mt-2">
                                    보기
                                </a>
                            </div>
                        </div>
                    </li>
                <% } %>
                </ul>
            <% } %>


        <% } %>

        </div>
    </div>


    <!-- --------------------------- 내가 쓴 게시글 --------------------------- -->
    <div class="card shadow-sm mt-5 mb-5">
        <div class="card-header bg-light">
            <b>📄 내가 작성한 게시글 (<%= myPosts.size() %>)</b>
        </div>

        <div class="card-body">

        <% if (myPosts.isEmpty()) { %>

            <p class="text-muted">작성한 게시글이 없습니다.</p>

        <% } else { %>

            <ul class="list-group">

            <% for (Post p : myPosts) { %>

                <li class="list-group-item">

                    <div class="d-flex justify-content-between align-items-center">

                        <a href="<%=ctx%>/post.jsp?id=<%=p.getId()%>&from=mypage"
                           class="fw-semibold text-decoration-none">
                           <%= p.getTitle() %>
                        </a>

                        <div class="text-end">

                            <small class="text-muted me-3">
                                <%= new java.text.SimpleDateFormat("yyyy-MM-dd")
                                        .format(p.getCreatedAt()) %>
                            </small>

                            <a href="<%=ctx%>/edit.jsp?id=<%=p.getId()%>&from=mypage"
                               class="btn btn-sm btn-outline-primary">
                               수정
                            </a>

                            <form action="<%=ctx%>/deletePost" method="post"
                                  class="d-inline"
                                  onsubmit="return confirm('정말 삭제하시겠습니까?');">
                                <input type="hidden" name="postId" value="<%=p.getId()%>">
                                <input type="hidden" name="from" value="mypage">
                                <button type="submit" class="btn btn-sm btn-outline-danger">
                                  삭제
                                </button>
                            </form>

                        </div>

                    </div>

                </li>

            <% } %>

            </ul>

        <% } %>

        </div>
    </div>

</div>

</main>


<footer class="mt-auto py-4 bg-dark text-light">
  <div class="container text-center">
    <small>Copyright &copy; 볼피또 2025</small>
  </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
