<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>샌드박스 본인인증(모의)</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
</head>
<body class="p-3">
    <h5 class="mb-3">샌드박스 본인인증(모의)</h5>
    <form method="post" action="authCallback.jsp">
        <div class="mb-3">
            <label class="form-label">이름</label>
            <input type="text" name="name" class="form-control" placeholder="홍길동" required>
        </div>
        <div class="mb-3">
            <label class="form-label">휴대폰 번호</label>
            <input type="text" name="phone" class="form-control" placeholder="01012345678" required>
        </div>
        <div class="mb-3">
            <label class="form-label">생년월일(YYYYMMDD)</label>
            <input type="text" name="birth" class="form-control" placeholder="19990101" required>
        </div>

        <!-- 실제 토스라면 authKey 등을 넘기지만, 여기선 직접 정보를 넘겨서 시뮬레이션 -->
        <button type="submit" class="btn btn-primary w-100">인증 완료(모의)</button>
    </form>
</body>
</html>
