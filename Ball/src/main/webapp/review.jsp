<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
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

    // 요청한 장소
    String place = request.getParameter("place");
    if (place == null) place = "";

    // DAO
    MatchDAO matchDAO = new MatchDAO();
    PlaceReviewDAO reviewDAO = new PlaceReviewDAO();

    // 리뷰 목록
    List<Map<String, Object>> reviewList = null;
    double avg = 0;
    int count = 0;

    if (!place.isBlank()) {
        reviewList = reviewDAO.listByPlace(place);

        for (var r : reviewList) {
            avg += Double.parseDouble(String.valueOf(r.get("rating")));
        }
        count = reviewList.size();
        if (count > 0) avg /= count;
    }

    // 전체 장소 목록
    Set<String> allPlaces = new HashSet<>();
    for (Match m : matchDAO.getTodayMatches()) {
        allPlaces.add(m.getLocation());
    }

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
</head>

<body>

<!-- 상단 네비바 (community.jsp 디자인 동일) -->
<nav class="navbar navbar-expand-lg" style="background-color:#212529;">
    <div class="container px-4 px-lg-5 d-flex justify-content-between align-items-center">
        <a class="navbar-brand text-white fw-bold" href="<%=ctx%>/main.jsp">볼피또</a>

        <div>
            <span class="text-light me-3"><%=loginUser.getName()%>님 환영합니다</span>
            <a class="text-light me-3 text-decoration-none" href="<%=ctx%>/main.jsp">홈</a>
            <a class="text-light me-3 text-decoration-none" href="<%=ctx%>/mypage.jsp">마이페이지</a>
            <a class="text-light text-decoration-none" href="<%=ctx%>/logout.jsp">로그아웃</a>
        </div>
    </div>
</nav>

<div class="container px-4 px-lg-5 my-4">

    <h2 class="fw-bold mb-3">전체 리뷰 모아보기</h2>

    <!-- 장소 선택 -->
    <form method="get" class="row g-2 mb-4">
        <div class="col-md-6">
            <select name="place" class="form-select">
                <option value="">📍 전체 리뷰 보기</option>
                <% for (String p : allPlaces) { %>
                    <option value="<%=p%>" <%=p.equals(place) ? "selected" : ""%>><%=p%></option>
                <% } %>
            </select>
        </div>
        <div class="col-md-2">
            <button class="btn btn-primary w-100">조회</button>
        </div>
    </form>

    <!-- 장소 정보 -->
    <% if (!place.isBlank()) { %>
    <div class="card mb-4 shadow-sm">
        <div class="card-body">
            <h4 class="fw-bold"><%=place%></h4>
            <div class="mt-2">
                <span style="font-size: 22px; color: #FFC107;">★</span>
                <span class="fw-bold"><%=String.format("%.1f", avg)%></span>
                <span class="text-muted small">(리뷰 <%=count%>개)</span>
            </div>
        </div>
    </div>
    <% } %>

    <!-- 리뷰 리스트 -->
    <div class="mb-4">
        <% if (place.isBlank()) { %>
            <div class="text-muted">⚠ 장소를 선택하면 리뷰가 표시됩니다.</div>

        <% } else if (reviewList == null || reviewList.isEmpty()) { %>
            <div class="text-muted">아직 리뷰가 없습니다. 첫 리뷰를 남겨보세요!</div>

        <% } else { 
            for (var r : reviewList) {

                int rating = Integer.parseInt(String.valueOf(r.get("rating")));
                String stars = "★".repeat(rating);
                int writerId = Integer.parseInt(String.valueOf(r.get("userId")));
        %>

        <div class="card mb-3 shadow-sm">
            <div class="card-body">

                <div>
                    <span style="color:#FFC107; font-size:18px;"><%=stars%></span>
                    <span class="text-muted small ms-2">(<%=rating%>)</span>
                </div>

                <div class="small text-muted mb-1">
                    <%=r.get("user")%> · <%=r.get("createdAt")%>
                </div>

                <div><%=r.get("content")%></div>

                <!-- 작성자만 수정/삭제 버튼 표시 -->
                <% if (writerId == loginUserId) { %>
                <div class="mt-2">
                    <button class="btn btn-sm btn-outline-primary"
                        onclick="openEditModal(<%=r.get("id")%>, '<%=r.get("content")%>', <%=rating%>)">
                        수정
                    </button>

                    <button class="btn btn-sm btn-outline-danger"
                        onclick="deleteReview(<%=r.get("id")%>)">
                        삭제
                    </button>
                </div>
                <% } %>

            </div>
        </div>

        <% } } %>
    </div>

    <!-- 리뷰 작성 버튼 -->
    <% if (!place.isBlank()) { %>
        <% if (canWrite) { %>
            <button class="btn btn-success w-100 py-2" onclick="openWriteModal()">리뷰 작성하기</button>
        <% } else { %>
            <button class="btn btn-secondary w-100 py-2" disabled>⚠ 예약한 경기장만 리뷰 작성이 가능합니다</button>
        <% } %>
    <% } %>

</div>


<!-- 리뷰 작성 모달 -->
<div class="modal fade" id="writeModal" tabindex="-1">
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
<div class="modal fade" id="editModal" tabindex="-1">
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
/* -------- 리뷰 작성 -------- */
function openWriteModal() {
    const modal = new bootstrap.Modal(document.getElementById("writeModal"));
    modal.show();
}

function submitReview() {
    const place = "<%=place%>";
    const content = document.getElementById("reviewContent").value.trim();
    const rating = document.getElementById("reviewRating").value;

    if (!content) {
        alert("리뷰 내용을 입력하세요");
        return false;
    }

    const params = new URLSearchParams();
    params.append("action", "addByPlace");
    params.append("place", place);
    params.append("content", content);
    params.append("rating", rating);

    fetch("<%=ctx%>/review", {
        method: "POST",
        body: params
    })
    .then(res => res.json())
    .then(data => {
        if (data.ok) {
            alert("리뷰 등록되었습니다!");
            location.reload();
        } else {
            alert("등록 실패");
        }
    });

    return false;
}


/* -------- 리뷰 수정 -------- */
function openEditModal(id, content, rating) {
    document.getElementById("editReviewId").value = id;
    document.getElementById("editReviewContent").value = content;
    document.getElementById("editReviewRating").value = rating;

    const modal = new bootstrap.Modal(document.getElementById("editModal"));
    modal.show();
}

function updateReview() {
    const id = document.getElementById("editReviewId").value;
    const content = document.getElementById("editReviewContent").value.trim();
    const rating = document.getElementById("editReviewRating").value;

    if (!content) {
        alert("내용을 입력하세요");
        return false;
    }

    const params = new URLSearchParams();
    params.append("action", "update");
    params.append("id", id);
    params.append("content", content);
    params.append("rating", rating);

    fetch("<%=ctx%>/review", {
        method: "POST",
        body: params
    })
    .then(res => res.json())
    .then(data => {
        if (data.ok) {
            alert("리뷰가 수정되었습니다");
            location.reload();
        } else {
            alert("수정 실패");
        }
    });

    return false;
}


/* -------- 리뷰 삭제 -------- */
function deleteReview(id) {
    if (!confirm("정말 삭제하시겠습니까?")) return;

    const params = new URLSearchParams();
    params.append("action", "delete");
    params.append("id", id);

    fetch("<%=ctx%>/review", {
        method: "POST",
        body: params
    })
    .then(res => res.json())
    .then(data => {
        if (data.ok) {
            alert("삭제되었습니다");
            location.reload();
        } else {
            alert("삭제 실패");
        }
    });
}
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
