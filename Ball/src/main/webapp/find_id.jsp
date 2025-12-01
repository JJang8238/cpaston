<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/include/header.jsp" %>

<link rel="stylesheet"
      href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">

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
    .find-title {
        text-align: center;
        font-size: 32px;
        font-weight: 700;
        margin-top: 40px;
        margin-bottom: 30px;
    }

    /* 카드 박스 (login.jsp와 동일 스타일 적용) */
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

    /* 링크 */
    .helper-links {
        text-align: center;
        margin-top: 18px;
    }
    .helper-links a {
        font-size: 14px;
        color: #777;
        text-decoration: none;
        margin: 0 8px;
    }
    .helper-links a:hover {
        color: #2BAE66;
        text-decoration: underline;
    }
</style>

<main>

    <h2 class="find-title">아이디 찾기</h2>

    <div class="find-box">

        <form action="find_id_result.jsp" method="post">

            <div class="mb-3">
                <label class="form-label">가입한 이름</label>
                <input type="text" name="name" class="form-control" required>
            </div>

            <div class="mb-4">
                <label class="form-label">가입한 이메일</label>
                <input type="email" name="email" class="form-control" required>
            </div>

            <button type="submit" class="btn-green">아이디 찾기</button>

            <div class="helper-links">
                <a href="login.jsp">로그인</a> |
                <a href="find_pw.jsp">비밀번호 찾기</a>
            </div>

        </form>
    </div>

</main>

<%@ include file="/include/footer.jsp" %>
