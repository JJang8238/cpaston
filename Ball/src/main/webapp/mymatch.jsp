<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="dao.ReservationDAO, dto.MyReservation" %>
<%@ include file="include/header.jsp" %>

<%
    // 로그인 세션에서 userId를 꺼내 쓰는 형태 (없다면 임시 1)
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) { userId = 1; } // 데모용

    ReservationDAO rdao = new ReservationDAO();
    List<MyReservation> myList = rdao.findByUserId(userId);
%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>내 예약 경기 - 리뷰 작성</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<style>
  body{background:#f8f9fa}
  .section-title{font-weight:700;letter-spacing:.2px}
  .table thead th{background:#f1f3f5}
</style>
</head>
<body class="container py-4">

<h2 class="section-title mb-3">내 예약 경기</h2>

<% if (myList == null || myList.isEmpty()) { %>
  <div class="alert alert-secondary">아직 예약한 경기가 없습니다.</div>
<% } else { %>
  <table class="table table-hover align-middle bg-white">
    <thead>
      <tr>
        <th style="width:130px">날짜</th>
        <th style="width:100px">시간</th>
        <th>장소</th>
        <th style="width:130px" class="text-end">리뷰</th>
      </tr>
    </thead>
    <tbody>
    <% for (MyReservation m : myList) { %>
      <tr>
        <td><%= m.getMatchDate() %></td>
        <td><%= m.getMatchTime() %></td>
        <td><%= m.getLocation() %></td>
        <td class="text-end">
          <button class="btn btn-sm btn-primary"
                  onclick="openReviewModal(<%= m.getMatchReservationId() %>, '<%= m.getLocation().replace("'", "\\'") %>', '<%= m.getMatchDate() %>', '<%= m.getMatchTime() %>')">
            리뷰 작성
          </button>
        </td>
      </tr>
    <% } %>
    </tbody>
  </table>
<% } %>

<!-- 리뷰 작성 모달 -->
<div class="modal fade" id="rvModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 id="rvTitle" class="modal-title">리뷰 작성</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <label class="form-label">별점(선택, 1~5)</label>
        <input id="rvRating" type="number" min="1" max="5" class="form-control mb-3" placeholder="예: 5">

        <label class="form-label">리뷰 내용</label>
        <textarea id="rvText" class="form-control" rows="4" placeholder="경기/시설/매너 등 자유롭게 적어주세요."></textarea>
      </div>
      <div class="modal-footer">
        <button class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
        <button class="btn btn-primary" onclick="saveMatchReview()">등록</button>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
let currentMatchId = null;
const modal = new bootstrap.Modal(document.getElementById('rvModal'));

function openReviewModal(matchId, place, date, time){
  currentMatchId = matchId;
  document.getElementById('rvTitle').textContent = place + ' (' + date + ' ' + time + ') 리뷰 작성';
  document.getElementById('rvRating').value = '';
  document.getElementById('rvText').value = '';
  modal.show();
}

async function saveMatchReview(){
  const text = document.getElementById('rvText').value.trim();
  const rating = document.getElementById('rvRating').value.trim();
  if(!currentMatchId){ alert('경기 정보가 없습니다.'); return; }
  if(!text){ alert('리뷰 내용을 입력해 주세요.'); return; }

  const body = new URLSearchParams();
  body.append('action', 'addByMatch');
  body.append('matchId', String(currentMatchId));
  body.append('content', text);
  if(rating) body.append('rating', rating);

  try{
    const res = await fetch('review', {
      method:'POST',
      headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'},
      body
    });
    const out = await res.json();
    if(out.ok){
      modal.hide();
      alert('리뷰가 등록되었습니다!');
    }else{
      alert('리뷰 저장에 실패했습니다.');
    }
  }catch(e){
    alert('요청 중 오류가 발생했습니다: ' + e.message);
  }
}
</script>

<%@ include file="include/footer.jsp" %>
</body>
</html>
