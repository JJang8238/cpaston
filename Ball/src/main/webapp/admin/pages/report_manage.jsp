<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.PostDAO, dto.Post, java.util.*" %>

<%
    String ctx = request.getContextPath();

    PostDAO dao = new PostDAO();
    List<Post> list = dao.listByReportThreshold(1);  // 신고 1 이상 전부 보기

    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm");
%>

<h2 class="fw-bold mb-4">🚨 신고 게시글 관리</h2>

<p class="text-muted mb-3">총 신고된 게시글 : <b><%= list.size() %>건</b></p>

<table class="table table-bordered bg-white">
    <thead class="table-dark">
        <tr>
            <th>ID</th>
            <th>제목</th>
            <th>작성자</th>
            <th>신고수</th>
            <th>작성일</th>
            <th>관리</th>
        </tr>
    </thead>

    <tbody>
    <% if(list.isEmpty()) { %>
        <tr><td colspan="6" class="text-center py-4 text-muted">신고된 게시글이 없습니다.</td></tr>
    <% } else { 
        for(Post p : list) { %>

        <tr>
            <td><%= p.getId() %></td>
            <td><%= p.getTitle() %></td>
            <td><%= p.getAuthor() %></td>

            <!-- 신고수 배지 색상 -->
            <td>
                <% if(p.getReports() >= 3) { %>
                    <span class="badge bg-danger">🚨 신고 누적 3회</span>
                <% } else if(p.getReports() == 2) { %>
                    <span class="badge bg-warning text-dark">신고 2회</span>
                <% } else { %>
                    <span class="badge bg-warning-subtle text-dark">신고 1회</span>
                <% } %>
            </td>

            <td><%= sdf.format(p.getCreatedAt()) %></td>

            <td>
                <!-- 보기 버튼 -->
                <button class="btn btn-sm btn-primary"
                        onclick="openDetailModal('<%=p.getTitle()%>', `<%=p.getContent()%>`)">
                    보기
                </button>

                <!-- 삭제 버튼 (POST 전송) -->
                <form method="post" action="<%=ctx%>/deletePost" style="display:inline-block;"
                      onsubmit="return confirm('정말 삭제하시겠습니까?');">

                    <input type="hidden" name="postId" value="<%= p.getId() %>">
                    <input type="hidden" name="from" value="admin">

                    <button type="submit" class="btn btn-sm btn-danger">삭제</button>
                </form>
            </td>
        </tr>

    <%  }} %>
    </tbody>
</table>

<!-- ================================
     📌 모달 (경기 관리와 동일 스타일)
================================ -->
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
        width:600px;
        padding:25px;
        border-radius:12px;
        box-shadow:0 4px 20px rgba(0,0,0,0.25);
        max-height:80vh;
        overflow-y:auto;
    }
</style>

<!-- 📌 게시글 상세 보기 모달 -->
<div id="detailModal" class="modal-backdrop-custom">
    <div class="modal-box">
        <h4 id="detail-title" class="fw-bold mb-3"></h4>
        <div id="detail-content" class="mb-4"></div>

        <button class="btn btn-secondary w-100" onclick="closeDetailModal()">닫기</button>
    </div>
</div>

<!-- ================================
     📌 모달 스크립트
================================ -->
<script>
function openDetailModal(title, content) {
    document.getElementById("detail-title").innerHTML = title;
    document.getElementById("detail-content").innerHTML = content.replace(/\n/g, "<br>");
    document.getElementById("detailModal").style.display = "flex";
}

function closeDetailModal() {
    document.getElementById("detailModal").style.display = "none";
}
</script>
