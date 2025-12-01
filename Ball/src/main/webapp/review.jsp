<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true"%>
<%@ page import="dao.MatchDAO, dao.PlaceReviewDAO, dto.Match, dto.User, java.util.*" %>

<%
    // 로그인 체크
    Object loginObj = session.getAttribute("loginUser");
    if (loginObj == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    User loginUser = (User) loginObj;
    int loginUserId = loginUser.getId();
    String ctx = request.getContextPath();

    // 요청 장소
    String place = request.getParameter("place");
    if (place == null) place = "";

    // 정렬 옵션
    String sort = request.getParameter("sort");
    if (sort == null || sort.isBlank()) sort = "newest";

    // DAO
    MatchDAO matchDAO = new MatchDAO();
    PlaceReviewDAO reviewDAO = new PlaceReviewDAO();

    // 리뷰 목록 + 통계
    List<Map<String, Object>> reviewList = null;
    double avg = 0;
    int count = 0;
    int[] ratingCounts = new int[6];

    if (!place.isBlank()) {
        reviewList = reviewDAO.listByPlace(place, sort);

        for (var r : reviewList) {
            int rating = Integer.parseInt(String.valueOf(r.get("rating")));
            avg += rating;
            if (rating >= 1 && rating <= 5) ratingCounts[rating]++;
        }
        count = reviewList.size();
        if (count > 0) avg /= count;
    }

    // 전체 장소 목록
    Set<String> allPlaces = new HashSet<>();
    for (Match m : matchDAO.getTodayMatches()) allPlaces.add(m.getLocation());

    // 리뷰 작성 가능 여부
    boolean canWrite = false;
    if (!place.isBlank()) {
        for (Match m : matchDAO.getTodayMatchesByPlace(place)) {
            if (matchDAO.isUserReserved(loginUserId, m.getId())) {
                canWrite = true;
                break;
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>전체 리뷰 모아보기</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
    body {
        background-color:#f5f7fa;
        font-family:'Pretendard','Noto Sans KR',sans-serif;
    }

    /* ===== 상단 타이틀 영역 (community.jsp와 동일 느낌) ===== */
    .page-header-wrap{
        background:#ffffff;
        border-bottom:1px solid #e5e7eb;
    }
    .page-header-inner{
        padding:32px 0;
    }
    .page-title{
        font-weight:700;
        font-size:26px;
        margin-bottom:6px;
    }
    .page-subtitle{
        color:#6b7280;
        font-size:14px;
    }

    /* ===== 메인 영역 너비(카드 10%정도 좁게) ===== */
    .review-main{
        max-width:1000px;   /* 기본 container보다 살짝 좁게 */
        margin:0 auto;
    }

    /* ===== 카드 공통 스타일 (community 카드 느낌) ===== */
    .summary-card,
    .stats-card,
    .review-card{
        border-radius:16px;
        border:none;
        box-shadow:0 4px 16px rgba(15,23,42,0.06);
        background:#ffffff;
        font-size:0.96rem;
    }
    .summary-card{ margin-bottom:18px; }
    .stats-card{  margin-bottom:24px; }
    .review-card{ margin-bottom:16px; }

    .progress{ height:6px; }

    .star-big{
        font-size:22px;
        color:#FFC107;
        font-weight:700;
    }
    .star-small{
        font-size:18px;
        color:#FFC107;
    }

    .filter-row{
        margin:16px 0 20px;
    }
</style>

</head>

<body class="d-flex flex-column min-vh-100">

<!-- NAV -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container px-4">
        <a class="navbar-brand fw-bold" href="<%=ctx%>/main.jsp">볼피또</a>

        <div class="text-white ms-auto">
            <span class="me-3"><%=loginUser.getName()%> 님</span>
            <a href="<%=ctx%>/main.jsp" class="text-white text-decoration-none me-3">홈</a>
            <a href="<%=ctx%>/mypage.jsp" class="text-white text-decoration-none me-3">마이페이지</a>
            <a href="<%=ctx%>/logout.jsp" class="text-white text-decoration-none">로그아웃</a>
        </div>
    </div>
</nav>

<!-- 상단 타이틀 (커뮤니티와 동일 구조) -->
<div class="page-header-wrap">
  <div class="container page-header-inner">
    <div class="review-main">
      <h2 class="page-title mb-1">전체 리뷰 모아보기</h2>
      <p class="page-subtitle mb-0">이용자들이 남긴 진짜 리뷰를 한눈에 확인해 보세요.</p>
    </div>
  </div>
</div>

<main class="container flex-grow-1 py-4 pb-5">
  <div class="review-main">

    <!-- 검색 옵션 -->
    <form method="get" class="row g-2 filter-row">
        <div class="col-md-5">
            <select name="place" class="form-select">
                <option value="">📍 전체 리뷰 보기</option>
                <% for (String p : allPlaces) { %>
                    <option value="<%=p%>" <%= p.equals(place) ? "selected" : "" %>><%=p%></option>
                <% } %>
            </select>
        </div>

        <div class="col-md-3">
            <select name="sort" class="form-select">
                <option value="newest" <%= "newest".equals(sort)?"selected":"" %>>최신순</option>
                <option value="oldest" <%= "oldest".equals(sort)?"selected":"" %>>오래된순</option>
                <option value="high"   <%= "high".equals(sort)  ?"selected":"" %>>별점 높은순</option>
                <option value="low"    <%= "low".equals(sort)   ?"selected":"" %>>별점 낮은순</option>
            </select>
        </div>

        <div class="col-md-2">
            <button class="btn btn-primary w-100">조회</button>
        </div>
    </form>

    <!-- 장소 정보 + 통계 -->
    <% if (!place.isBlank()) { %>

    <!-- 선택한 장소 요약 카드 -->
    <div class="card summary-card">
        <div class="card-body">
            <h4 class="fw-bold mb-1"><%=place%></h4>
            <div class="mt-1">
                <span class="star-big">★</span>
                <span class="fw-bold" style="font-size:23px;">
                    <%=count>0 ? String.format("%.1f", avg) : "-"%>
                </span>
                <span class="text-muted small">(리뷰 <%=count%>개)</span>
            </div>
        </div>
    </div>

    <% if (reviewList != null && !reviewList.isEmpty()) { %>

    <!-- 리뷰 통계 카드 -->
    <div class="card stats-card">
        <div class="card-body">

            <h5 class="fw-bold mb-3">⭐ 리뷰 통계</h5>

            <div class="d-flex align-items-end gap-3 mb-3">
                <div style="font-size:40px; font-weight:800;">
                    <%=String.format("%.1f", avg)%>
                </div>
                <div class="text-muted small">
                    평균 별점<br>
                    총 <%=count%>개의 리뷰
                </div>
            </div>

            <% for (int r = 5; r >= 1; r--) { 
                int rc = ratingCounts[r];
                int percent = (count > 0) ? (int)Math.round(rc * 100.0 / count) : 0;
            %>
            <div class="d-flex align-items-center mb-1">
                <div style="width:55px;">★ <%=r%>점</div>

                <div class="flex-grow-1 mx-2">
                    <div class="progress">
                        <div class="progress-bar bg-primary" style="width:<%=percent%>%"></div>
                    </div>
                </div>

                <div style="width:40px;" class="text-end"><%=rc%>개</div>
            </div>
            <% } %>

        </div>
    </div>

    <% } } %>

    <!-- 리뷰 목록 -->
    <% if (place.isBlank()) { %>

        <div class="alert alert-info text-center mt-3">
            📍 장소를 선택하면 리뷰가 표시됩니다.
        </div>

    <% } else if (reviewList == null || reviewList.isEmpty()) { %>

        <div class="alert alert-warning text-center mt-3">
            아직 리뷰가 없습니다. 첫 리뷰를 남겨보세요!
        </div>

    <% } else { %>

        <% for (var r : reviewList) {

            int rating = Integer.parseInt(String.valueOf(r.get("rating")));
            String stars = "★".repeat(rating);
            int writerId = Integer.parseInt(String.valueOf(r.get("userId")));

        %>

        <div class="card review-card">
            <div class="card-body">

                <!-- 별점 -->
                <div class="mb-1">
                    <span class="star-small"><%=stars%></span>
                    <span class="text-muted small ms-2">(<%=rating%>)</span>
                </div>

                <!-- 작성자/날짜 -->
                <div class="small text-muted mb-1">
                    <%=r.get("user")%> · <%=r.get("created_at")%>
                </div>

                <!-- 내용 -->
                <div class="mb-2"><%=r.get("content")%></div>

                <% if (writerId == loginUserId) { %>
                <button class="btn btn-sm btn-outline-primary me-1"
                    onclick="openEditModal(<%=r.get("id")%>, '<%=r.get("content")%>', <%=rating%>)">수정</button>

                <button class="btn btn-sm btn-outline-danger"
                    onclick="deleteReview(<%=r.get("id")%>)">삭제</button>
                <% } %>

            </div>
        </div>

        <% } %>
    <% } %>

    <!-- 작성 버튼 -->
    <% if (!place.isBlank()) { %>
        <% if (canWrite) { %>
            <button class="btn btn-primary btn-lg w-100 mt-3" onclick="openWriteModal()">리뷰 작성하기</button>
        <% } else { %>
            <button class="btn btn-secondary btn-lg w-100 mt-3" disabled>
                ⚠ 예약한 경기장을 이용한 사용자만 리뷰 작성 가능
            </button>
        <% } %>
    <% } %>

  </div> <!-- /review-main -->
</main>

<!-- 리뷰 작성 모달 -->
<div class="modal fade" id="writeModal">
  <div class="modal-dialog">
    <div class="modal-content">
      <form onsubmit="return submitReview();">

        <div class="modal-header">
          <h5 class="modal-title">리뷰 작성</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>

        <div class="modal-body">
          <textarea id="reviewContent" class="form-control mb-3" rows="4" placeholder="내용을 입력하세요"></textarea>

          <select id="reviewRating" class="form-select">
            <option value="5">⭐ 5점</option>
            <option value="4">⭐ 4점</option>
            <option value="3">⭐ 3점</option>
            <option value="2">⭐ 2점</option>
            <option value="1">⭐ 1점</option>
          </select>
        </div>

        <div class="modal-footer">
          <button type="submit" class="btn btn-primary w-100">등록</button>
        </div>

      </form>
    </div>
  </div>
</div>

<!-- 리뷰 수정 모달 -->
<div class="modal fade" id="editModal">
  <div class="modal-dialog">
    <div class="modal-content">
      <form onsubmit="return updateReview();">

        <div class="modal-header">
          <h5 class="modal-title">리뷰 수정</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>

        <div class="modal-body">

          <input type="hidden" id="editReviewId">

          <textarea id="editReviewContent" class="form-control mb-3" rows="4"></textarea>

          <select id="editReviewRating" class="form-select">
            <option value="5">⭐ 5점</option>
            <option value="4">⭐ 4점</option>
            <option value="3">⭐ 3점</option>
            <option value="2">⭐ 2점</option>
            <option value="1">⭐ 1점</option>
          </select>

        </div>

        <div class="modal-footer">
          <button type="submit" class="btn btn-primary w-100">수정 완료</button>
        </div>

      </form>
    </div>
  </div>
</div>

<script>
/* 리뷰 작성 */
function openWriteModal() {
    new bootstrap.Modal(document.getElementById("writeModal")).show();
}

function submitReview() {
    const place = "<%=place%>";
    const content = document.getElementById("reviewContent").value.trim();
    const rating = document.getElementById("reviewRating").value;

    if (!content) { alert("리뷰 내용을 입력하세요"); return false; }

    const params = new URLSearchParams();
    params.append("action", "addByPlace");
    params.append("place", place);
    params.append("content", content);
    params.append("rating", rating);

    fetch("<%=ctx%>/review", { method:"POST", body:params })
        .then(res => res.json())
        .then(data => {
            if (data.ok) { alert("리뷰 등록되었습니다!"); location.reload(); }
            else alert("등록 실패");
        });

    return false;
}

/* 리뷰 수정 */
function openEditModal(id, content, rating) {
    document.getElementById("editReviewId").value = id;
    document.getElementById("editReviewContent").value = content;
    document.getElementById("editReviewRating").value = rating;

    new bootstrap.Modal(document.getElementById("editModal")).show();
}

function updateReview() {
    const id = document.getElementById("editReviewId").value;
    const content = document.getElementById("editReviewContent").value.trim();
    const rating = document.getElementById("editReviewRating").value;

    if (!content) { alert("내용을 입력하세요"); return false; }

    const params = new URLSearchParams();
    params.append("action", "update");
    params.append("id", id);
    params.append("content", content);
    params.append("rating", rating);

    fetch("<%=ctx%>/review", { method:"POST", body:params })
        .then(res => res.json())
        .then(data => {
            if (data.ok) { alert("리뷰가 수정되었습니다"); location.reload(); }
            else alert("수정 실패");
        });

    return false;
}

/* 리뷰 삭제 */
function deleteReview(id) {
    if (!confirm("정말 삭제하시겠습니까?")) return;

    const params = new URLSearchParams();
    params.append("action", "delete");
    params.append("id", id);

    fetch("<%=ctx%>/review", { method:"POST", body:params })
        .then(res => res.json())
        .then(data => {
            if (data.ok) { alert("삭제되었습니다"); location.reload(); }
            else alert("삭제 실패");
        });
}
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
