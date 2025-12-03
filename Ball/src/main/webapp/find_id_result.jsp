<%@ page import="dao.UserDAO" %>
<%@ page import="dto.User" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    request.setCharacterEncoding("UTF-8");

    String name = request.getParameter("name");
    String email = request.getParameter("email");

    User foundUser = null;

    try (UserDAO dao = new UserDAO()) {
        foundUser = dao.findByNameAndEmail(name, email);
    }
%>

<jsp:include page="/include/header.jsp" />

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
        flex: 1; 
    }

    /* 제목 */
    .result-title {
        text-align: center;
        font-size: 32px;
        font-weight: 700;
        margin-top: 40px;
        margin-bottom: 30px;
    }

    /* 결과 카드 */
    .result-box {
        max-width: 480px;
        background: #ffffff;
        padding: 32px 28px;
        border-radius: 16px;
        margin: 0 auto;
        box-shadow: 0 8px 26px rgba(0,0,0,0.08);
        text-align: center;
    }

    .result-text {
        font-size: 18px;
        font-weight: 600;
        color: #333;
        margin-bottom: 25px;
    }

    /* 버튼 (login.jsp와 동일) */
    .btn-green {
        height: 48px;
        width: 100%;
        background: #2BAE66;
        color: white;
        font-size: 17px;
        border-radius: 10px;
        border: none;
        font-weight: 600;
        margin-top: 10px;
    }
    .btn-green:hover {
        background: #239956;
    }
</style>

<main>

    <h2 class="result-title">아이디 찾기 결과</h2>

    <div class="result-box">

        <% if (foundUser == null) { %>
            <p class="result-text" style="color:#d9534f;">
                입력한 정보와 일치하는 아이디가 없습니다.
            </p>
        <% } else { %>
            <p class="result-text">
                회원님의 아이디는<br>
                <b><%= foundUser.getUsername() %></b> 입니다.
            </p>
        <% } %>

        <button class="btn-green" onclick="location.href='login.jsp'">로그인 하러가기</button>

    </div>

</main>

<%@ include file="/include/footer.jsp" %>