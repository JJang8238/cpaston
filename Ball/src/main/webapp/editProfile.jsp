<%@ page contentType="text/html; charset=UTF-8" session="true" %>
<%@ page import="dto.User" %>

<%
    User user = (User) session.getAttribute("loginUser");
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
    <style>
        body {
            font-family: 'Arial', sans-serif;
            background-color: #f9f9f9;
            margin: 0;
            padding: 0;
        }
        .container {
            max-width: 450px;
            margin: 50px auto;
            padding: 30px;
            background-color: #fff;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        h2 {
            margin-bottom: 20px;
            font-size: 1.5em;
            text-align: center;
        }
        .profile-image {
            display: block;
            margin: 0 auto 15px auto;
            width: 100px;
            height: 100px;
            border-radius: 50%;
            object-fit: cover;
            background-color: #eee;
        }
        form label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        form input[type="text"],
        form input[type="email"],
        form input[type="password"],
        form input[type="file"] {
            width: 100%;
            padding: 8px 10px;
            margin-bottom: 15px;
            border: 1px solid #ccc;
            border-radius: 6px;
            box-sizing: border-box;
        }
        button {
            width: 100%;
            padding: 10px;
            background-color: #0d6efd;
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 1em;
        }
        button:hover {
            background-color: #0b5ed7;
        }
        .back-link {
            display: block;
            text-align: center;
            margin-top: 15px;
            color: #555;
            text-decoration: none;
            font-size: 0.9em;
        }
        .back-link:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>나의 계정</h2>

        <form action="updateProfile.jsp" method="post" enctype="multipart/form-data">
            <!-- 프로필 이미지 -->
            <img src="<%= user.getProfileImage() != null ? "uploads/" + user.getProfileImage() : "default-profile.png" %>" 
                 alt="프로필 이미지" class="profile-image">

            <label>사진 업로드</label>
            <input type="file" name="profileImage" accept="image/*">

            <label>이름</label>
            <input type="text" name="name" value="<%= user.getName() %>">

            <label>이메일</label>
            <input type="email" name="email" value="<%= user.getEmail() %>" readonly>

            <label>새 비밀번호</label>
            <input type="password" name="newPassword" placeholder="변경 시만 입력">

            <button type="submit">변경사항 저장</button>
        </form>

        <a href="mypage.jsp" class="back-link">← 마이페이지로 돌아가기</a>
    </div>
</body>
</html>


