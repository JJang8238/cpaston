<%@ page contentType="text/html; charset=UTF-8" session="true" %>
<%@ page import="dto.User" %>

<%
    User user = (User) session.getAttribute("loginUser");
    if (user == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    String ctx = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>프로필 수정</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

<style>
    body {
        background: #f3f6fb;
        font-family: "Pretendard", sans-serif;
    }
    .page-title {
        font-size: 30px;
        font-weight: 700;
        margin-bottom: 30px;
        color: #1f2a44;
    }
    .box-card {
        background: #fff;
        border-radius: 18px;
        box-shadow: 0 8px 25px rgba(0,0,0,0.06);
        padding: 30px;
    }
    .profile-img {
        width: 160px;
        height: 160px;
        border-radius: 50%;
        object-fit: cover;
        border: 5px solid #e3ebff;
        background: #fff;
        margin-bottom: 18px;
    }
    .upload-area {
        border: 2px dashed #c9d6ff;
        border-radius: 16px;
        padding: 28px;
        background: #f8faff;
        cursor: pointer;
        transition: 0.2s;
    }
    .upload-area:hover {
        background: #eef3ff;
        border-color: #708bff;
    }
</style>
</head>

<!-- ★★★ footer를 하단 고정시키는 핵심 ★★★ -->
<body class="d-flex flex-column min-vh-100">

<!-- 본문 영역 — footer 위의 공간 -->
<main class="flex-grow-1">

<div class="container py-5">

    <h1 class="page-title">
        <i class="bi bi-person-circle me-2"></i> 프로필 수정
    </h1>

	<form action="updateProfile" method="post" enctype="multipart/form-data">
    <div class="row g-4">

        <!-- 왼쪽 프로필 -->
        <div class="col-md-4">
            <div class="box-card text-center">

                <img id="previewImg" 
                     src="<%= (user.getProfileImage() != null && !user.getProfileImage().isEmpty()) 
                         ? (ctx + "/uploads/" + user.getProfileImage())
                         : (ctx + "/assets/img/1.png") %>"
                     class="profile-img">

                <input type="file" name="profileImage" id="profileInput"
                       accept="image/*" style="display:none;">

                <div class="upload-area" onclick="document.getElementById('profileInput').click();">
                    <i class="bi bi-upload" style="font-size:32px; color:#4a64ff;"></i>
                    <div class="mt-2 fw-semibold">프로필 사진 변경</div>
                </div>

            </div>
        </div>

        <!-- 오른쪽 정보 -->
        <div class="col-md-8">
            <div class="box-card">

                <form action="updateProfile" method="post" enctype="multipart/form-data">

                    <label class="fw-bold mt-2">이름</label>
                    <input type="text" name="name" class="form-control mb-3"
                           value="<%= user.getName() %>">

                    <label class="fw-bold">이메일</label>
                    <input type="email" class="form-control mb-3" 
                           value="<%= user.getEmail() %>" readonly>

                    <label class="fw-bold">새 비밀번호</label>
                    <input type="password" name="newPassword"
                           class="form-control mb-4" placeholder="변경 시에만 입력해주세요">

                    <button type="submit" class="btn btn-primary w-100 py-2 fw-bold">
                        변경사항 저장
                    </button>
                </form>

                <div class="text-center mt-3">
                    <a href="mypage.jsp" class="text-secondary small">
                        ← 마이페이지로 돌아가기
                    </a>
                </div>

            </div>
        </div>

    </div>
</div>

</main>
<!-- ★★★ main 끝 ★★★ -->


<!-- ★★★ footer — 항상 가장 아래 ★★★ -->
<footer class="py-4 bg-dark text-light">
  <div class="container text-center">

      <div class="mb-1" style="font-size: 20px; font-weight: 700;">
          ⚽ Ballpitto – Play Together, Enjoy More
      </div>

      <div class="small text-secondary">
          📍 위치 기반 경기 매칭&nbsp;&nbsp;|&nbsp;&nbsp;
          👥 파트너 찾기&nbsp;&nbsp;|&nbsp;&nbsp;
          📝 리뷰 & 커뮤니티
      </div>

  </div>
</footer>


<script>
document.getElementById("profileInput").addEventListener("change", function(e){
    let file = e.target.files[0];
    if (!file) return;

    let reader = new FileReader();
    reader.onload = function(event){
        document.getElementById("previewImg").src = event.target.result;
    };
    reader.readAsDataURL(file);
});
</script>

</body>
</html>
