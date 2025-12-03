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
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>프로필 수정</title>
</head>
<body>
    <h2><%= user.getName() %> 님의 프로필 수정</h2>

    <form action="updateProfile.jsp" method="post" enctype="multipart/form-data">
        <label>이름:</label><br>
        <input type="text" name="name" value="<%= user.getName() %>"><br><br>

        <label>이메일:</label><br>
        <input type="email" name="email" value="<%= user.getEmail() %>"><br><br>

        <label>새 비밀번호:</label><br>
        <input type="password" name="newPassword" placeholder="변경 시만 입력"><br><br>

        <label>프로필 사진:</label><br>
        <input type="file" name="profileImage" accept="image/*"><br><br>

        <button type="submit">수정하기</button>
    </form>

    <p><a href="mypage.jsp">← 마이페이지로 돌아가기</a></p>
</body>
</html>
