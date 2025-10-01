<%@ page contentType="text/html; charset=UTF-8" session="true" %>
<%@ page import="dto.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>마이페이지</title>
</head>
<body>
    <h2><%= user.getName() %>님의 마이페이지</h2>
    <!-- 여기에 사용자 정보 표시나 수정 기능 추가 가능 -->
</body>
</html>
