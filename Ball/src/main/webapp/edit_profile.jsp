<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="dto.User" %>
<%
    // 로그인 여부 확인
    User user = (User) session.getAttribute("user");
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
</head>
<body class="bg-light">

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-md-6">
            <div class="card shadow-sm">
                <div class="card-body p-4">
                    <h3 class="mb-4 text-center fw-bold">프로필 수정</h3>

                    <!-- ✅ multipart/form-data 로 변경 -->
                    <form action="update_profile.jsp" method="post" enctype="multipart/form-data">

                        <!-- 프로필 이미지 미리보기 -->
                        <div class="text-center mb-3">
                            <img src="<%= (user.getProfileImage() != null && !user.getProfileImage().isEmpty()) ? user.getProfileImage() : ctx + "/assets/img/profile-default.png" %>" 
                                 alt="프로필 이미지" class="rounded-circle" 
                                 style="width:120px; height:120px; object-fit:cover;">
                        </div>

                        <div class="mb-3">
                            <label class="form-label">프로필 이미지 변경</label>
                            <input type="file" class="form-control" name="profileImage" accept="image/*">
                        </div>

                        <div class="mb-3">
                            <label class="form-label">아이디 (Username)</label>
                            <input type="text" class="form-control" value="<%= user.getUsername() %>" readonly>
                            <div class="form-text">아이디는 수정할 수 없습니다.</div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">이름 (Name)</label>
                            <input type="text" class="form-control" name="name" value="<%= user.getName() %>" required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">이메일 (Email)</label>
                            <input type="email" class="form-control" name="email" value="<%= user.getEmail() %>" required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">새 비밀번호 (선택)</label>
                            <input type="password" class="form-control" name="newPassword" placeholder="변경하지 않으려면 비워두세요.">
                        </div>

                        <div class="d-flex gap-2 mt-4">
                            <button type="submit" class="btn btn-primary w-100">저장하기</button>
                            <a href="mypage.jsp" class="btn btn-outline-secondary w-100">취소</a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

