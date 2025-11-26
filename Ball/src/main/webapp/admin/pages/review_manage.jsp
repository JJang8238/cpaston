<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>

<%
    List<String> places = (List<String>) request.getAttribute("places");
    List<Map<String, Object>> list = (List<Map<String, Object>>) request.getAttribute("reviewList");
    String selected = (String) request.getAttribute("selectedPlace");
    String ctx = request.getContextPath();
%>

<div class="container-fluid px-4">

    <!-- 제목 -->
    <h3 class="fw-bold mb-4">⭐ 리뷰 관리</h3>

    <!-- 필터 영역 -->
    <div class="card shadow-sm mb-4">
        <div class="card-body">
            <form class="row g-3" method="get" action="<%=ctx%>/admin/place-review">
                <div class="col-auto">
                    <select class="form-select" name="place">
                        <option value="">전체 리뷰 보기</option>
                        <% if (places != null) {
                               for (String p : places) { %>
                            <option value="<%=p%>" <%= (p.equals(selected) ? "selected" : "") %>>
                                <%=p%>
                            </option>
                        <% } } %>
                    </select>
                </div>

                <div class="col-auto">
                    <button class="btn btn-primary px-4">검색</button>
                </div>
            </form>
        </div>
    </div>

    <!-- 리뷰 테이블 -->
    <div class="card shadow-sm">
        <div class="card-body p-0">
            <table class="table table-hover table-bordered align-middle mb-0">
                <thead class="table-dark text-center">
                <tr>
                    <th style="width:60px">ID</th>
                    <th style="width:200px">장소명</th>
                    <th style="width:120px">작성자</th>
                    <th style="width:80px">평점</th>
                    <th>내용</th>
                    <th style="width:180px">작성일</th>
                    <th style="width:90px">관리</th>
                </tr>
                </thead>

                <tbody>
                <% if (list == null || list.isEmpty()) { %>
                    <tr>
                        <td colspan="7" class="text-center text-muted py-4">
                            등록된 리뷰가 없습니다.
                        </td>
                    </tr>
                <% } else {
                       for (Map<String,Object> r : list) { %>

                    <tr>
                        <td class="text-center fw-semibold"><%= r.get("id") %></td>
                        <td><%= r.get("place_name") %></td>
                        <td class="text-center"><%= r.get("user") %></td>
                        <td class="text-center"><%= r.get("rating") %>★</td>
                        <td><%= r.get("content") %></td>
                        <td class="text-center"><%= r.get("created_at") %></td>

                        <td class="text-center">
                            <form method="post" action="<%=ctx%>/admin/place-review" style="display:inline;">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="id" value="<%= r.get("id") %>">
                                <button class="btn btn-sm btn-danger"
                                        onclick="return confirm('이 리뷰를 삭제할까요?');">
                                    삭제
                                </button>
                            </form>
                        </td>
                    </tr>

                <% } } %>
                </tbody>

            </table>
        </div>
    </div>

</div>
