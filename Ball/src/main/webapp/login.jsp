<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="include/header.jsp" %>

<!-- 로그인 페이지 디자인 통일 -->
<style>
    body {
        background-color: #f4f6f9;
        font-family: 'Pretendard','Noto Sans KR',sans-serif;
        display: flex;
        flex-direction: column;
        min-height: 100vh;
    }
    main {
        flex: 1;
    }

    /* 제목 */
    .login-title {
        text-align: center;
        font-size: 32px;
        font-weight: 700;
        margin-top: 40px;
        margin-bottom: 30px;
    }

    /* 카드형 로그인 박스 */
    .login-card {
        max-width: 480px;
        background: #ffffff;
        padding: 32px 28px;
        border-radius: 16px;
        margin: 0 auto;
        box-shadow: 0 8px 26px rgba(0,0,0,0.08);
    }

    /* 입력창 */
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

    /* input-group 자연스럽게 붙이기 */
    .input-group .form-control {
        border-top-right-radius: 0 !important;
        border-bottom-right-radius: 0 !important;
    }
    .input-group .btn {
        border-top-left-radius: 0 !important;
        border-bottom-left-radius: 0 !important;
        height: 48px;
        border-color: #c7d8ff;
        font-size: 14px;
        font-weight: 600;
    }

    /* 로그인 버튼 */
    .btn-login {
        height: 48px;
        width: 100%;
        background: #2BAE66;
        color: white;
        font-size: 17px;
        border-radius: 10px;
        border: none;
        font-weight: 600;
    }
    .btn-login:hover {
        background: #239956;
    }

    /* 아래 링크 */
    .helper-links {
        text-align: center;
        margin-top: 16px;
    }
    .helper-links a {
        font-size: 14px;
        color: #777;
        text-decoration: none;
        margin: 0 10px;
    }
    .helper-links a:hover {
        color: #2BAE66;
        text-decoration: underline;
    }

</style>

<main>

    <h2 class="login-title">로그인</h2>

    <div class="login-card">

        <form action="login_process.jsp" method="post">

            <!-- 아이디 -->
            <div class="mb-3">
                <label class="form-label" for="username">아이디</label>
                <input type="text" name="username" id="username" class="form-control" required>
            </div>

            <!-- 비밀번호 -->
            <div class="mb-4">
                <label class="form-label" for="password">비밀번호</label>
                <div class="input-group">
                    <input type="password" name="password" id="password" class="form-control" required>
                    <button class="btn btn-outline-secondary" type="button" onclick="togglePassword()">보기</button>
                </div>
            </div>

            <button type="submit" class="btn-login">로그인</button>

            <!-- 아이디/비밀번호 찾기 -->
            <div class="helper-links">
                <a href="find_id.jsp">아이디 찾기</a> |
                <a href="find_pw.jsp">비밀번호 찾기</a>
            </div>

        </form>
    </div>

</main>

<script>
function togglePassword() {
    const pw = document.getElementById("password");
    const btn = event.target;

    if (pw.type === "password") {
        pw.type = "text";
        btn.innerText = "숨기기";
    } else {
        pw.type = "password";
        btn.innerText = "보기";
    }
}
</script>

<%@ include file="include/footer.jsp" %>