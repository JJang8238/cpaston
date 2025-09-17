<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="include/header.jsp" %>

<style>
    body {
        display: flex;
        flex-direction: column;
        min-height: 100vh;
    }
    main {
        flex: 1;
    }
    .helper-links {
        text-align: center;
        margin-top: 10px;
    }
    .helper-links a {
        font-size: 0.9em;
        margin: 0 10px;
        text-decoration: none;
        color: #6c757d;
    }
    .helper-links a:hover {
        text-decoration: underline;
        color: #0d6efd;
    }
</style>

<main>
    <h2 class="mb-4 text-center mt-4">로그인</h2>

    <form action="login_process.jsp" method="post" class="mx-auto" style="max-width: 500px;">
        <div class="mb-3">
            <label for="username" class="form-label">아이디</label>
            <input type="text" name="username" id="username" class="form-control" required>
        </div>

        <div class="mb-3">
            <label for="password" class="form-label">비밀번호</label>
            <div class="input-group">
                <input type="password" name="password" id="password" class="form-control" required>
                <button class="btn btn-outline-secondary" type="button" onclick="togglePassword()">보기</button>
            </div>
        </div>

        <button type="submit" class="btn btn-primary w-100">로그인</button>

        <!-- 🔽 아이디/비밀번호 찾기 링크 -->
        <div class="helper-links">
            <a href="find_id.jsp">아이디 찾기</a> |
            <a href="find_password.jsp">비밀번호 찾기</a>
        </div>
    </form>
</main>

<script>
function togglePassword() {
    const pwField = document.getElementById("password");
    const btn = event.target;

    if (pwField.type === "password") {
        pwField.type = "text";
        btn.innerText = "숨기기";
    } else {
        pwField.type = "password";
        btn.innerText = "보기";
    }
}
</script>

<%@ include file="include/footer.jsp" %>
