<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/include/header.jsp" %>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>비밀번호 찾기</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
    body {
        background-color: #f4f6f9;
        font-family: 'Pretendard','Noto Sans KR',sans-serif;

        /* login.jsp와 동일한 구조 */
        display: flex;
        flex-direction: column;
        min-height: 100vh;
    }

    main {
        flex: 1; /* footer를 아래로 밀기 위한 영역 */
    }

    /* 제목 */
    .pw-title {
        text-align: center;
        font-size: 32px;
        font-weight: 700;
        margin-top: 40px;
        margin-bottom: 30px;
    }

    /* 입력 박스 */
    .find-box {
        max-width: 480px;
        background: #ffffff;
        padding: 32px 28px;
        border-radius: 16px;
        margin: 0 auto;
        box-shadow: 0 8px 26px rgba(0,0,0,0.08);
    }

    .form-label {
        font-weight: 600;
        color: #333;
    }
    .form-control {
        height: 48px;
        background-color: #eef4ff;
        font-size: 15px;
        border-radius: 10px;
    }
    .form-control:focus {
        border-color: #2BAE66;
        box-shadow: 0 0 0 3px rgba(43,174,102,0.15);
    }

    /* 버튼 */
    .btn-main {
        height: 48px;
        width: 100%;
        background: #2BAE66;
        color: white;
        font-size: 17px;
        font-weight: 600;
        border-radius: 10px;
        border: none;
        margin-top: 10px;
    }
    .btn-main:hover {
        background: #239956;
    }

</style>
</head>

<body>

<main>

    <h2 class="pw-title">비밀번호 찾기</h2>

    <div class="find-box">

        <!-- ⭐ 다음 페이지는 new_password.jsp로 가기 전, 검증하는 find_pw_check.jsp -->
        <form action="find_pw_check.jsp" method="post">

            <label class="form-label">아이디</label>
            <input type="text" name="username" class="form-control mb-3" required>

            <label class="form-label">가입한 이메일</label>
            <input type="email" name="email" class="form-control mb-4" required>

            <button type="submit" class="btn-main">다음</button>

        </form>

    </div>

</main>

<%@ include file="/include/footer.jsp" %>

</body>
</html>
