<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="dao.PostDAO" %>
<%@ page import="dto.Post" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    int threshold = 3;  // 원하는 신고 기준값
    PostDAO dao = new PostDAO();
    List<Post> reportedList = dao.listByReportThreshold(threshold);


    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>신고 게시글 관리</title>

<style>
    .report-title {
        font-size: 26px;
        font-weight: 700;
        margin-bottom: 20px;
    }

    .report-table-container {
        background: #fff;
        border-radius: 8px;
        padding: 15px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    }

    table {
        width: 100%;
        border-collapse: collapse;
    }

    th {
        background: #1f2937;
        color: #fff;
        padding: 12px;
        font-size: 14px;
        font-weight: 600;
        border-bottom: 1px solid #ddd;
        text-align: center;
    }

    td {
        padding: 12px;
        border-bottom: 1px solid #eee;
        text-align: center;
        font-size: 14px;
    }

    tr:hover td {
        background: #f0f4ff;
    }

    .empty {
        padding: 50px 0;
        text-align: center;
        font-size: 16px;
        color: #666;
    }
</style>

<div class="report-title">⭐ 신고 게시글 관리</div>

<div class="report-table-container">
    <table>
        <tr>
            <th>ID</th>
            <th>제목</th>
            <th>작성자</th>
            <th>신고수</th>
            <th>작성일</th>
            <th>관리</th>
        </tr>

        <% if (reportedList.isEmpty()) { %>
            <tr>
                <td colspan="6" class="empty">등록된 게시글이 없습니다.</td>
            </tr>
        <% } else {
               for (Post p : reportedList) {
        %>
            <tr>
                <td><%= p.getId() %></td>
                <td><%= p.getTitle() %></td>
                <td><%= p.getAuthor() %></td>
                <td><%= p.getReports() %></td>
                <td><%= sdf.format(p.getCreatedAt()) %></td>
                <td>
                    <button class="btn btn-danger btn-sm"
                        onclick="location.href='deletePost.jsp?id=<%=p.getId()%>'">
                        삭제
                    </button>
                </td>
            </tr>
        <% } } %>
    </table>
</div>


</body>
</html>

