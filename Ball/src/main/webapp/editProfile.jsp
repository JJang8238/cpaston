<%@ page contentType="text/html; charset=UTF-8" session="true" %>
<%@ page import="dto.User" %>

<%
    User user = (User) session.getAttribute("loginUser");
    if (user == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    String ctx = request.getContextPath();
    String profileImg = (user.getProfileImage() != null && !user.getProfileImage().isEmpty())
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
            background-color: #f5f7fa;
        }
        .edit-card {
            max-width: 600px;
            margin: 70px auto;
            padding: 40px;
            background: #fff;
            border-radius: 18px;
            box-shadow: 0 6px 24px rgba(0, 0, 0, 0.08);
        }
        .profile-img {
            width: 150px;
            height: 150px;
            object-fit: cover;
            border-radius: 50%;
            display: block;
            margin: 0 auto;
            border: 4px solid #fff;
            box-shadow: 0 3px 15px rgba(0,0,0,0.15);
        }
        .title-line {
            border-left: 4px solid #0d6efd;
            padding-left: 10px;
            font-weight: bold;
            font-size: 20px;
            margin-bottom: 25px;
        }
    </style>
</head>

<body>

<div class="edit-card">

    <h3 class="title-line">프로필 수정</h3>

    <form action="updateProfile" method="post" enctype="multipart/form-data">

        <!-- 프로필 이미지 미리보기 -->
        <img id="previewImg" src="<%=profileImg%>" class="profile-img mb-3">

        <div class="mb-3 text-center">
            <label class="form-label fw-semibold">프로필 사진 변경</label>
            <input type="file" name="profileImage" class="form-control" accept="image/*" onchange="previewImage(event)">
        </div>

        <div class="mb-3">
            <label class="form-label fw-semibold">이름</label>
            <input type="text" name="name" class="form-control" value="<%= user.getName() %>">
        </div>

        <div class="mb-3">
            <label class="form-label fw-semibold">이메일</label>
            <input type="email" name="email" class="form-control" value="<%= user.getEmail() %>" readonly>
        </div>

        <div class="mb-3">
            <label class="form-label fw-semibold">새 비밀번호 (선택)</label>
            <input type="password" name="newPassword" class="form-control" placeholder="변경 시에만 입력하세요">
        </div>

        <div class="d-flex gap-2 mt-4">
            <button type="submit" class="btn btn-primary w-50 fw-semibold">저장</button>
            <a href="mypage.jsp" class="btn btn-outline-secondary w-50">취소</a>
        </div>

    </form>

</div>

<script>
function previewImage(event) {
    const preview = document.getElementById("previewImg");
    preview.src = URL.createObjectURL(event.target.files[0]);
}
</script>

</body>
</html>
