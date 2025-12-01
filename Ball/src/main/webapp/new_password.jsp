<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    dto.User resetUser = (dto.User) session.getAttribute("resetUser");
    if (resetUser == null) {
        response.sendRedirect("find_pw.jsp");
        return;
    }
%>

<%@ include file="/include/header.jsp" %>

<style>
    body {
        background-color: #f4f6f9;
        font-family: 'Pretendard','Noto Sans KR',sans-serif;
        display:flex;
        flex-direction:column;
        min-height:100vh;
    }
    main { flex:1; }

    .title {
        text-align:center;
        font-size:32px;
        font-weight:700;
        margin-top:40px;
        margin-bottom:30px;
    }

    .pw-box {
        max-width:480px;
        background:white;
        padding:32px 28px;
        border-radius:16px;
        margin:0 auto;
        box-shadow:0 8px 26px rgba(0,0,0,0.08);
        text-align:center;
    }

    .btn-green {
        height:48px;
        width:100%;
        background:#2BAE66;
        color:white;
        font-size:17px;
        border-radius:10px;
        border:none;
        font-weight:600;
        margin-top:10px;
    }
    .btn-green:hover {
        background:#239956;
    }
</style>

<main>

    <h2 class="title">새 비밀번호 설정</h2>

    <div class="pw-box">

        <form action="update_password.jsp" method="post">

            <label class="form-label fw-bold">새 비밀번호</label>
            <input type="password" name="password1" class="form-control mb-3" required>

            <label class="form-label fw-bold">비밀번호 확인</label>
            <input type="password" name="password2" class="form-control mb-4" required>

            <button class="btn-green" type="submit">비밀번호 변경</button>

        </form>

    </div>

</main>

<%@ include file="/include/footer.jsp" %>
