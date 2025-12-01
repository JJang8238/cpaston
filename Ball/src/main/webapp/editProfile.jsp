<%@ page contentType="text/html; charset=UTF-8" session="true" %>
<%@ page import="dto.User" %>

<%
    User user = (User) session.getAttribute("loginUser");
    if (user == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    String ctx = request.getContextPath();

    String profilePath = (user.getProfileImage() != null && !user.getProfileImage().isEmpty())
            ? "uploads/" + user.getProfileImage()
            : ctx + "/assets/img/profile-default.png";
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>프로필 수정</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body {
            background-color: #f2f4f7;
            font-family: 'Arial', sans-serif;
        }

        .edit-wrapper {
            max-width: 1100px;
            margin: 60px auto;
            background: white;
            border-radius: 16px;
            padding: 50px 60px;
            box-shadow: 0 7px 20px rgba(0,0,0,0.08);
        }

        .left-title {
            border-left: 5px solid #2BAE66;
            padding-left: 15px;
            font-size: 22px;
            font-weight: 700;
            color: #2BAE66;
            margin-bottom: 20px;
        }

        .profile-img {
            width: 130px;
            height: 130px;
            border-radius: 50%;
            border: 4px solid #e5e5e5;
            object-fit: cover;
            background: #fafafa;
            display: block;
            margin: 0 auto;
        }

        .img-change-text {
            text-align: center;
            margin-top: 10px;
            color: #2BAE66;
            font-weight: 600;
        }

        /* 파일 업로드 박스 */
        .upload-box {
            width: 100%;
            padding: 16px;
            border: 2px dashed #cfcfcf;
            border-radius: 10px;
            background: #fafafa;
            text-align: center;
            cursor: pointer;
            color: #666;
            font-size: 15px;
            margin-bottom: 20px;
            transition: 0.25s;
        }

        .upload-box:hover {
            border-color: #2BAE66;
            background: #f3fff8;
        }

        .upload-box input[type="file"] {
            display: none;
        }

        label {
            font-weight: 600;
            margin-bottom: 6px;
        }

        input[type="text"],
        input[type="email"],
        input[type="password"] {
            padding: 12px;
            width: 100%;
            border-radius: 10px;
            border: 1px solid #ddd;
            background: #fafafa;
            margin-bottom: 18px;
        }

        input:focus {
            border-color: #2BAE66;
            outline: none;
            box-shadow: 0 0 0 0.15rem rgba(43,174,102,0.25);
        }

        .btn-save {
            width: 100%;
            background-color: #2BAE66;
            border: none;
            padding: 14px;
            border-radius: 10px;
            font-size: 17px;
            font-weight: bold;
            color: white;
        }

        .btn-save:hover {
            background-color: #249a5e;
        }

        .back-link {
            text-align: center;
            display: block;
            margin-top: 20px;
            color: #666;
            text-decoration: none;
        }
    </style>
</head>

<body>


        <!-- 🔥 반드시 서블릿으로 요청해야 함 -->
        <form action="updateProfile" method="post" enctype="multipart/form-data">
            <!-- 프로필 이미지 -->
            <img src="<%= user.getProfileImage() != null ? "uploads/" + user.getProfileImage() : "default-profile.png" %>" 
                 alt="프로필 이미지" class="profile-image">

    <div class="row">
        <div class="col-md-4 d-flex align-items-start">
            <div class="left-title">프로필 수정</div>
        </div>

        <div class="col-md-4 text-center">
            <img src="<%= profilePath %>" class="profile-img">
            <div class="img-change-text">프로필 사진 변경</div>
        </div>
    </div>

    <div class="row mt-4">
        <div class="col-md-12">

            <form action="updateProfile" method="post" enctype="multipart/form-data">

                <!-- 업로드 박스 -->
                <label>사진 업로드</label>
                <label class="upload-box" id="uploadBox">
                    <span id="fileText">클릭하여 파일 선택</span>
                    <input type="file" name="profileImage" id="fileInput" accept="image/*">
                </label>

                <label>이름</label>
                <input type="text" name="name" value="<%= user.getName() %>">

                <label>이메일</label>
                <input type="email" name="email" value="<%= user.getEmail() %>" readonly>

                <label>새 비밀번호</label>
                <input type="password" name="newPassword" placeholder="변경 시만 입력">

                <button type="submit" class="btn-save">변경사항 저장</button>
            </form>

            <a href="mypage.jsp" class="back-link">← 마이페이지로 돌아가기</a>

        </div>
    </div>

</div>

<!-- 파일명 표시 스크립트 -->
<script>
document.getElementById("uploadBox").addEventListener("click", function() {
    document.getElementById("fileInput").click();
});

document.getElementById("fileInput").addEventListener("change", function() {
    let fileName = this.files.length > 0 ? this.files[0].name : "클릭하여 파일 선택";
    document.getElementById("fileText").innerText = fileName;
});
</script>

</body>
</html>
