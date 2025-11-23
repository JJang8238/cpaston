<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.MatchDAO, dto.Match, java.util.*" %>

<%
    String ctx = request.getContextPath();
    MatchDAO dao = new MatchDAO();
    List<Match> list = dao.getAllMatches();
%>

<h2 class="fw-bold mb-4">⚽ 경기 관리</h2>

<button class="btn btn-primary mb-3" onclick="openCreateModal()">
    ➕ 경기 생성
</button>

<table class="table table-bordered bg-white">
    <thead class="table-dark">
        <tr>
            <th>ID</th>
            <th>장소</th>
            <th>날짜</th>
            <th>시간</th>
            <th>정원</th>
            <th>관리</th>
        </tr>
    </thead>

    <tbody>
    <% for (Match m : list) { %>
        <tr>
            <td><%=m.getId()%></td>
            <td><%=m.getLocation()%></td>
            <td><%=m.getMatchDate()%></td>
            <td><%=m.getMatchTime()%></td>
            <td><%=m.getMaxPlayers()%></td>

            <td>
                <button class="btn btn-warning btn-sm"
                        onclick="openEditModal(
                            '<%=m.getId()%>',
                            '<%=m.getLocation()%>',
                            '<%=m.getMatchDate()%>',
                            '<%=m.getMatchTime()%>',
                            '<%=m.getMaxPlayers()%>'
                        )">수정</button>

                <button class="btn btn-danger btn-sm"
                        onclick="if(confirm('삭제하시겠습니까?')) location.href='<%=ctx%>/matchController?action=delete&id=<%=m.getId()%>'">
                    삭제
                </button>
            </td>
        </tr>
    <% } %>
    </tbody>
</table>

<!-- ==========================================
     📌 공통 모달 배경
========================================== -->
<style>
    .modal-backdrop-custom {
        position: fixed;
        top:0; left:0;
        width:100%; height:100%;
        background:rgba(0,0,0,0.45);
        display:none;
        justify-content:center;
        align-items:center;
        z-index:9999;
    }
    .modal-box {
        background:white;
        width:500px;
        padding:30px;
        border-radius:12px;
        box-shadow:0 4px 20px rgba(0,0,0,0.25);
    }
</style>

<!-- ==========================================
     📌 수정 모달
========================================== -->
<div id="editModal" class="modal-backdrop-custom">
    <div class="modal-box">
        <h4 class="mb-3">경기 수정</h4>

        <form method="post" action="<%=ctx%>/matchController">
            <input type="hidden" name="action" value="update">
            <input type="hidden" id="edit-id" name="id">

            <label>장소</label>
            <input type="text" id="edit-place" name="place" class="form-control mb-2" required>

            <label>날짜</label>
            <input type="date" id="edit-date" name="date" class="form-control mb-2" required>

            <label>시간</label>
            <input type="time" id="edit-time" name="time" class="form-control mb-2" required>

            <label>정원</label>
            <input type="number" id="edit-max" name="max" class="form-control mb-4" required>

            <button class="btn btn-primary w-100 mb-2">수정 완료</button>
        </form>

        <button class="btn btn-secondary w-100" onclick="closeEditModal()">취소</button>
    </div>
</div>


<!-- ==========================================
     📌 경기 생성 모달 🆕
========================================== -->
<div id="createModal" class="modal-backdrop-custom">
    <div class="modal-box">
        <h4 class="mb-3">경기 생성</h4>

        <form method="post" action="<%=ctx%>/matchController">
            <input type="hidden" name="action" value="create">

            <label>장소</label>
            <input type="text" name="place" id="create-place" class="form-control mb-2" required>

            <label>날짜</label>
            <input type="date" name="date" id="create-date" class="form-control mb-2" required>

            <label>시간</label>
            <input type="time" name="time" id="create-time" class="form-control mb-2" required>

            <label>정원</label>
            <input type="number" name="max" id="create-max" class="form-control mb-4" required>

            <button class="btn btn-primary w-100 mb-2">생성</button>
        </form>

        <button class="btn btn-secondary w-100" onclick="closeCreateModal()">취소</button>
    </div>
</div>


<!-- ==========================================
     📌 모달 제어 스크립트
========================================== -->
<script>
    /* -----------------------
       🔧 시간 변환 (오전/오후 → 24H)
    ------------------------ */
    function normalizeTime(timeStr) {

        if (timeStr.includes("오전") || timeStr.includes("오후")) {
            timeStr = timeStr.replace("오전", "AM").replace("오후", "PM");
            let d = new Date("1970-01-01 " + timeStr);
            let h = String(d.getHours()).padStart(2, '0');
            let m = String(d.getMinutes()).padStart(2, '0');
            return `${h}:${m}`;
        }

        if (timeStr.length === 8) {
            return timeStr.substring(0, 5);
        }

        return timeStr;
    }

    /* -----------------------
       📌 수정 모달 열기
    ------------------------ */
    function openEditModal(id, place, date, time, max) {
        document.getElementById("edit-id").value = id;
        document.getElementById("edit-place").value = place;
        document.getElementById("edit-date").value = date;
        document.getElementById("edit-time").value = normalizeTime(time);
        document.getElementById("edit-max").value = max;

        document.getElementById("editModal").style.display = "flex";
    }

    function closeEditModal() {
        document.getElementById("editModal").style.display = "none";
    }

    /* -----------------------
       📌 경기 생성 모달 열기
    ------------------------ */
    function openCreateModal() {
        // 이전 입력값 초기화
        document.getElementById("create-place").value = "";
        document.getElementById("create-date").value = "";
        document.getElementById("create-time").value = "";
        document.getElementById("create-max").value = "";

        document.getElementById("createModal").style.display = "flex";
    }

    function closeCreateModal() {
        document.getElementById("createModal").style.display = "none";
    }
</script>
