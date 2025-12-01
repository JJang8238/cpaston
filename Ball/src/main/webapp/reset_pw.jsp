<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>비밀번호 재설정</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
body { background: #f5f7fa; }
.card { border-radius: 20px; padding: 25px; }
.btn-main {
    background: #28a745; border: none;
    border-radius: 10px; font-weight: bold;
    padding: 12px 0; color: white;
}
.btn-main:hover { opacity: .9; }
.title { font-size: 28px; font-weight: 700; }
.small-info { font-size: 13px; color: #7a7a7a; }
</style>
</head>

<body>

<div class="container d-flex justify-content-center" style="margin-top: 80px;">
    <div class="card shadow" style="width: 420px;">
        <div class="text-center mb-4 title">새 비밀번호 설정</div>

        <div class="mb-3">
            <label class="form-label">새 비밀번호</label>
            <input type="password" id="pw1" class="form-control form-control-lg" placeholder="6자리 이상 입력">
        </div>

        <div class="mb-3">
            <label class="form-label">새 비밀번호 확인</label>
            <input type="password" id="pw2" class="form-control form-control-lg" placeholder="다시 입력">
        </div>

        <button class="btn-main w-100" onclick="resetPw()">비밀번호 변경</button>

        <div id="msg" class="mt-3 text-center text-danger small-info"></div>
    </div>
</div>

<script>
function resetPw() {
    const p1 = document.getElementById("pw1").value;
    const p2 = document.getElementById("pw2").value;
    const msg = document.getElementById("msg");

    if (p1.length < 6) {
        msg.textContent = "비밀번호는 6자리 이상이어야 합니다.";
        return;
    }
    if (p1 !== p2) {
        msg.textContent = "비밀번호가 일치하지 않습니다.";
        return;
    }

    fetch("<%=request.getContextPath()%>/pw/reset", {
        method: "POST",
        headers: {"Content-Type":"application/x-www-form-urlencoded"},
        body: `newPw=${p1}`
    })
    .then(res => res.text())
    .then(text => {
        msg.textContent = text;
        if (text.includes("성공")) {
            setTimeout(() => location.href = "login.jsp", 1200);
        }
    });
}
</script>

</body>
</html>
