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
            display: flex;
            align-items: center;
            justify-content: center;
            text-align: center;
            margin-top: 15px;
            color: #555;
            text-decoration: none;
            font-size: 0.9em;
        }
        .back-link svg {
            margin-right: 6px;
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

        <!-- 마이페이지로 돌아가기 링크 + 부트스트랩 아이콘 -->
        <a href="mypage.jsp" class="back-link">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-arrow-up-left-square" viewBox="0 0 16 16">
              <path fill-rule="evenodd" d="M15 2a1 1 0 0 0-1-1H2a1 1 0 0 0-1 1v12a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1zM0 2a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2zm10.096 8.803a.5.5 0 1 0 .707-.707L6.707 6h2.768a.5.5 0 1 0 0-1H5.5a.5.5 0 0 0-.5.5v3.975a.5.5 0 0 0 1 0V6.707z"/>
            </svg>
            마이페이지로 돌아가기
        </a>
    </div>
</body>
</html>