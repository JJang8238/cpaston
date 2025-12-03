<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="dto.User, dao.PostDAO, dto.Post, dao.PlaceReviewDAO, dao.MatchReviewDAO, dao.MatchDAO, dto.Match, java.util.*" %>

<%
    /* --------------------------- 로그인 체크 --------------------------- */
    Object loginObj = session.getAttribute("loginUser");
    if (loginObj == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    User loginUser = (User) loginObj;

    int loginUserId = loginUser.getId();
    String ctx = request.getContextPath();

    String displayName =
        (loginUser.getName() != null && !loginUser.getName().isEmpty())
            ? loginUser.getName()
            : loginUser.getUsername();

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

    List<Map<String,Object>> placeLimit = (myPlaceReviews.size() > 5)
        ? myPlaceReviews.subList(0, 5)
        : myPlaceReviews;

    List<Map<String,Object>> matchLimit = (myMatchReviews.size() > 5)
        ? myMatchReviews.subList(0, 5)
        : myMatchReviews;

    /* --------------------------- 내가 예약한 경기 --------------------------- */
    MatchDAO matchDAOx = new MatchDAO();
    List<Match> myReservedMatches = matchDAOx.getMyReservedMatches(loginUserId);
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8" />
    <title>마이페이지</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body {
            background-color: #f5f7fa;
        }
        .profile-card {
            border: none;
            border-radius: 18px;
            box-shadow: 0 4px 18px rgba(0,0,0,0.07);
        }
        .section-card {
            border-radius: 14px;
            box-shadow: 0 4px 14px rgba(0,0,0,0.05);
            border: none;
        }
        .limit-box {
            max-height: 500px;
            overflow: hidden;
        }
        .title-line {
            border-left: 4px solid #0d6efd;
            padding-left: 10px;
            font-weight: bold;
            font-size: 18px;
        }
    </style>
</head>

<body class="d-flex flex-column min-vh-100">

<!-- --------------------------- 네비 --------------------------- -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark shadow-sm">
  <div class="container px-4">
    <a class="navbar-brand fw-bold" href="<%=ctx%>/main.jsp">볼피또</a>

    <button class="navbar-toggler" data-bs-toggle="collapse" data-bs-target="#nav">
      <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse" id="nav">
      <ul class="navbar-nav ms-auto">
        <li class="nav-item"><span class="nav-link disabled"><%=displayName%>님</span></li>
        <li class="nav-item"><a class="nav-link" href="<%=ctx%>/main.jsp">홈</a></li>
        <li class="nav-item"><a class="nav-link active fw-bold" href="<%=ctx%>/mypage.jsp">마이페이지</a></li>
        <li class="nav-item"><a class="nav-link" href="<%=ctx%>/logout.jsp">로그아웃</a></li>
      </ul>
    </div>
  </div>
</nav>


<!-- --------------------------- 메인 --------------------------- -->
<main class="flex-grow-1">
<div class="container py-5">

    <h2 class="fw-bold mb-4">마이페이지</h2>

    <div class="row g-4">

        <!-- -------------------- 프로필 카드 -------------------- -->
        <div class="col-lg-4">
            <div class="card profile-card text-center p-4">
                <img src="<%=fProfile%>" class="rounded-circle mx-auto mb-3"
                     style="width:150px;height:150px;object-fit:cover;border:4px solid #fff;box-shadow:0 3px 10px rgba(0,0,0,0.15);">

                <h4 class="fw-bold mb-0"><%=fName%></h4>
                <p class="text-muted mb-3"><small>역할(Role): <%=fRole%></small></p>

                <a href="<%=ctx%>/editProfile.jsp"
                   class="btn btn-primary w-100 fw-semibold">
                   프로필 수정
                </a>
            </div>
        </div>

        <!-- -------------------- 계정 정보 카드 -------------------- -->
        <div class="col-lg-8">
            <div class="card profile-card p-4">
                <h5 class="title-line mb-3">계정 정보</h5>

                <div class="row mb-3">
                    <div class="col-sm-4 text-muted">아이디</div>
                    <div class="col-sm-8 fw-semibold"><%=fUsername%></div>
                </div>

                <div class="row mb-3">
                    <div class="col-sm-4 text-muted">이름</div>
                    <div class="col-sm-8 fw-semibold"><%=fName%></div>
                </div>

                <div class="row mb-3">
                    <div class="col-sm-4 text-muted">이메일</div>
                    <div class="col-sm-8 fw-semibold"><%=fEmail%></div>
                </div>

                <div class="d-flex justify-content-end gap-2 mt-3">
                    <a href="<%=ctx%>/main.jsp" class="btn btn-outline-secondary">홈으로</a>
                    <a href="<%=ctx%>/logout.jsp" class="btn btn-outline-danger">로그아웃</a>
                </div>
            </div>
        </div>

    </div>

    <!-- --------------------------- 내가 쓴 리뷰 --------------------------- -->
    <div class="card section-card mt-5 p-4">
        <h5 class="title-line mb-3">⭐ 내가 작성한 리뷰 (<%= totalReviewCount %>)</h5>

        <% if (totalReviewCount == 0) { %>

            <p class="text-muted">작성한 리뷰가 없습니다.</p>

        <% } else { %>

            <!-- 장소 리뷰 -->
            <% if (!myPlaceReviews.isEmpty()) { %>
                <h6 class="fw-bold mt-3">📍 장소 리뷰</h6>

                <div id="placeReviewBox"
                     class="<%= (myPlaceReviews.size() > 5) ? "limit-box" : "" %>">

                    <ul class="list-group mb-3">
                    <% for (int i = 0; i < placeLimit.size(); i++) {
                           Map<String,Object> r = placeLimit.get(i); %>

                        <li class="list-group-item border-0 border-bottom py-3">

                            <strong class="d-block"><%= r.get("place_name") %></strong>

                            <span class="text-warning">
                                <%
                                    Object ratingObj = r.get("rating");
                                    int rating = (ratingObj != null)
                                            ? Integer.parseInt(String.valueOf(ratingObj))
                                            : 0;
                                    for (int s = 0; s < rating; s++) out.print("★");
                                %>
                            </span>
                            <span class="text-muted small">(<%=r.get("rating")%>)</span>

                            <div class="text-muted small"><%=r.get("created_at")%></div>
                            <div><%=r.get("content")%></div>

                        </li>

                    <% } %>
                    </ul>
                </div>

                <% if (myPlaceReviews.size() > 5) { %>
                    <button id="placeMoreBtn" class="btn btn-sm btn-outline-primary">더보기</button>
                <% } %>
            <% } %>

            <!-- 경기 리뷰 -->
            <% if (!myMatchReviews.isEmpty()) { %>
                <h6 class="fw-bold mt-4">⚽ 경기 리뷰</h6>

                <div id="matchReviewBox"
                     class="<%= (myMatchReviews.size() > 5) ? "limit-box" : "" %>">

                    <ul class="list-group mb-3">
                    <% for (int i = 0; i < matchLimit.size(); i++) {
                           Map<String,Object> r = matchLimit.get(i); %>

                        <li class="list-group-item border-0 border-bottom py-3">

                            <strong class="d-block">경기 ID: <%=r.get("match_id")%></strong>

                            <span class="text-warning">
                                <%
                                    Object ratingObj = r.get("rating");
                                    int rating = (ratingObj != null)
                                            ? Integer.parseInt(String.valueOf(ratingObj))
                                            : 0;
                                    for (int s = 0; s < rating; s++) out.print("★");
                                %>
                            </span>
                            <span class="text-muted small">(<%=r.get("rating")%>)</span>

                            <div class="text-muted small"><%=r.get("created_at")%></div>
                            <div><%=r.get("content")%></div>

                        </li>

                    <% } %>
                    </ul>
                </div>

                <% if (myMatchReviews.size() > 5) { %>
                    <button id="matchMoreBtn" class="btn btn-sm btn-outline-primary">더보기</button>
                <% } %>
            <% } %>

        <% } %>
    </div>


    <!-- --------------------------- 내가 예약한 경기 --------------------------- -->
    <div class="card section-card mt-5 p-4">
        <h5 class="title-line mb-3">📅 내가 예약한 경기 (<%= myReservedMatches.size() %>)</h5>

        <% if (myReservedMatches.isEmpty()) { %>

            <p class="text-muted">예약한 경기가 없습니다.</p>

        <% } else { %>

            <div class="table-responsive">
            <table class="table table-bordered bg-white mt-2">
                <thead class="table-light">
                    <tr>
                        <th>날짜</th>
                        <th>시간</th>
                        <th>장소</th>
                        <th>현재 인원</th>
                        <th>정원</th>
                        <th>상태</th>
                        <th>관리</th>
                    </tr>
                </thead>

                <tbody>
                <% for (Match m : myReservedMatches) { %>
                    <tr>
                        <td><%= m.getMatchDate() %></td>
                        <td><%= m.getMatchTime() %></td>
                        <td><%= m.getLocation() %></td>
                        <td><%= m.getCurrentPlayers() %></td>
                        <td><%= m.getMaxPlayers() %></td>
                        <td><%= m.getMatchStatus() %></td>

                        <td>
                            <form action="<%=ctx%>/reserve" method="post"
                                  onsubmit="return confirm('정말 예약을 취소하시겠습니까?');">
                                <input type="hidden" name="action" value="cancel">
                                <input type="hidden" name="matchId" value="<%=m.getId()%>">

                                <button type="submit" class="btn btn-sm btn-outline-danger">
                                    취소
                                </button>
                            </form>
                        </td>

                    </tr>
                <% } %>
                </tbody>

            </table>
            </div>

        <% } %>
    </div>


    <!-- --------------------------- 내가 쓴 게시글 --------------------------- -->
    <div class="card section-card mt-5 mb-5 p-4">
        <h5 class="title-line mb-3">📄 내가 작성한 게시글 (<%= myPosts.size() %>)</h5>

        <% if (myPosts.isEmpty()) { %>

            <p class="text-muted">작성한 게시글이 없습니다.</p>

        <% } else { %>

            <ul class="list-group">

            <% for (Post p : myPosts) { %>

                <li class="list-group-item border-0 border-bottom py-3">

                    <div class="d-flex justify-content-between align-items-center">

                        <a href="<%=ctx%>/post.jsp?id=<%=p.getId()%>&from=mypage"
                           class="fw-semibold text-decoration-none">
                           <%= p.getTitle() %>
                        </a>

                        <div class="text-end">

                            <small class="text-muted me-3">
                                <%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(p.getCreatedAt()) %>
                            </small>

                            <a href="<%=ctx%>/edit.jsp?id=<%=p.getId()%>&from=mypage"
                               class="btn btn-sm btn-outline-primary me-1">
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
</main>

<!-- --------------------------- 푸터 --------------------------- -->
<footer class="mt-auto py-4 bg-dark text-light">
  <div class="container text-center">
    <small>Copyright &copy; 볼피또 2025</small>
  </div>
</footer>


<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
document.addEventListener("DOMContentLoaded", function() {
    // 장소 리뷰 더보기
    var placeBtn = document.getElementById("placeMoreBtn");
    var placeHidden = document.getElementById("placeReviewHidden");
    var placeBox = document.getElementById("placeReviewBox");

    if (placeBtn && placeHidden && placeBox) {
        placeBtn.addEventListener("click", function() {
            placeHidden.classList.remove("d-none");
            placeBox.classList.remove("limit-box");
            placeBtn.style.display = "none";
        });
    }

    // 경기 리뷰 더보기
    var matchBtn = document.getElementById("matchMoreBtn");
    var matchHidden = document.getElementById("matchReviewHidden");
    var matchBox = document.getElementById("matchReviewBox");

    if (matchBtn && matchHidden && matchBox) {
        matchBtn.addEventListener("click", function() {
            matchHidden.classList.remove("d-none");
            matchBox.classList.remove("limit-box");
            matchBtn.style.display = "none";
        });
    }
});
</script>

</body>
</html>