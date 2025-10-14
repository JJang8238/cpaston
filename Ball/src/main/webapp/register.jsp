<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
  <% String ctx=request.getContextPath(); // 예: /Ball %>
    <!DOCTYPE html>
    <html lang="ko">

    <head>
      <meta charset="UTF-8">
      <title>회원가입 - 플랩풋볼</title>
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
      <style>
        body {
          background-color: #f8f9fa;
        }

        .navbar-brand {
          font-weight: 700;
          letter-spacing: .5px;
        }

        .form-card {
          max-width: 760px;
        }

        .eye-btn {
          width: 44px;
        }

        .valid-msg {
          color: #198754;
        }

        .invalid-msg {
          color: #dc3545;
        }
      </style>
    </head>

    <body>

      <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
          <a class="navbar-brand" href="<%=ctx%>/index.jsp">플랩풋볼</a>
          <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#nav">
            <span class="navbar-toggler-icon"></span>
          </button>
          <div id="nav" class="collapse navbar-collapse">
            <ul class="navbar-nav ms-auto mb-2 mb-lg-0">
              <li class="nav-item"><a class="nav-link active" href="<%=ctx%>/index.jsp">Home</a></li>
              <li class="nav-item"><a class="nav-link" href="<%=ctx%>/login.jsp">로그인</a></li>
              <li class="nav-item"><a class="nav-link" href="<%=ctx%>/register.jsp">회원가입</a></li>
            </ul>
          </div>
        </div>
      </nav>

      <div class="container py-5">
        <h2 class="mb-4 fw-bold">회원가입</h2>

        <div class="alert alert-warning form-card mx-auto">
          이메일 인증을 완료해야 가입폼이 활성화됩니다. (코드는 10분간 유효)
        </div>

        <!-- 이메일 인증 -->
        <div class="card shadow-sm form-card mx-auto mb-4">
          <div class="card-body">
            <div class="text-center mb-3">
              <div class="badge text-bg-primary px-3 py-2">이메일 본인인증</div>
            </div>

            <div class="mb-3">
              <label for="email" class="form-label">이메일</label>
              <div class="input-group">
                <input type="email" class="form-control" id="email" name="email" placeholder="you@example.com" required>
                <button class="btn btn-outline-secondary" type="button" id="btnSendCode" onclick="sendEmailCode()">인증코드
                  보내기</button>
              </div>
              <div class="form-text">메일함(스팸함 포함)을 확인하세요. 코드는 10분간 유효합니다.</div>
            </div>

            <div class="mb-1">
              <label for="emailCode" class="form-label">이메일 인증코드</label>
              <div class="input-group">
                <input type="text" class="form-control" id="emailCode" maxlength="6" placeholder="6자리">
                <button class="btn btn-primary" type="button" id="btnVerifyCode" onclick="verifyEmailCode()">코드
                  확인</button>
              </div>
            </div>
          </div>
        </div>

        <!-- 가입 폼 -->
        <div class="card shadow-sm form-card mx-auto">
          <div class="card-body">
            <form action="<%=ctx%>/register" method="post" onsubmit="return validateBeforeSubmit();">

              <!-- ✅ 서버로 반드시 넘어가야 하므로 폼 안으로 이동 -->
              <input type="hidden" id="emailVerified" name="emailVerified" value="0">

              <!-- 아이디 -->
              <div class="mb-3">
                <label for="username" class="form-label">아이디</label>
                <div class="input-group">
                  <input type="text" class="form-control" id="username" name="username" minlength="4" maxlength="12"
                    required disabled placeholder="영문/숫자 4~12자">
                  <button class="btn btn-outline-secondary" type="button" id="btnCheckDup" disabled
                    onclick="checkIdDup()">중복확인</button>
                </div>
                <div id="idHelp" class="form-text">영문/숫자 4~12자</div>
              </div>

              <!-- 비밀번호 -->
              <div class="mb-3">
                <label for="password" class="form-label">비밀번호</label>
                <div class="input-group">
                  <input type="password" class="form-control" id="password" name="password" minlength="8" maxlength="20"
                    required disabled placeholder="8~20자, 영문/숫자/특수문자 중 2종 이상">
                  <button class="btn btn-outline-secondary eye-btn" type="button" tabindex="-1"
                    onclick="toggleEye('password')">👁</button>
                </div>
                <div id="pwRule" class="form-text">
                  8~20자, <b>영문</b>/<b>숫자</b>/<b>특수문자</b> 중 2종 이상 포함 권장
                </div>
                <ul class="small mb-0">
                  <li id="ruleLen" class="text-muted">길이 8~20자</li>
                  <li id="ruleKinds" class="text-muted">문자 종류 2종 이상(영문/숫자/특수)</li>
                </ul>
              </div>

              <!-- 비밀번호 확인 -->
              <div class="mb-3">
                <label for="passwordConfirm" class="form-label">비밀번호 확인</label>
                <div class="input-group">
                  <input type="password" class="form-control" id="passwordConfirm" minlength="8" maxlength="20" required
                    disabled placeholder="비밀번호 재입력">
                  <button class="btn btn-outline-secondary eye-btn" type="button" tabindex="-1"
                    onclick="toggleEye('passwordConfirm')">👁</button>
                </div>
                <div id="pwHelp" class="form-text"></div>
              </div>

              <!-- 이름 -->
              <div class="mb-4">
                <label for="name" class="form-label">이름</label>
                <input type="text" class="form-control" id="name" name="name" required disabled>
              </div>

              <!-- 이메일(서버 전달용) -->
              <input type="hidden" name="email" id="emailHidden">

              <div class="d-grid">
                <button id="btnRegister" type="submit" class="btn btn-success btn-lg" disabled>가입하기</button>
              </div>
            </form>
          </div>
        </div>
      </div>

      <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
      <script>
        // ===== 유효성 검사/이메일 인증/중복확인 로직 (이전과 동일, 핵심만 발췌) =====
        const ids = {
          username: document.getElementById('username'),
          btnCheckDup: document.getElementById('btnCheckDup'),
          password: document.getElementById('password'),
          passwordConfirm: document.getElementById('passwordConfirm'),
          name: document.getElementById('name'),
          btnRegister: document.getElementById('btnRegister'),
          emailVerified: document.getElementById('emailVerified')
        };

        function setDisabled(d) {
          ['username', 'btnCheckDup', 'password', 'passwordConfirm', 'name', 'btnRegister']
            .forEach(id => { const el = document.getElementById(id); if (el) el.disabled = d; });
        }
        function enableForm() { setDisabled(false); }
        function toggleEye(id) { const el = document.getElementById(id); if (el) el.type = (el.type === 'password' ? 'text' : 'password'); }

        // 아이디 유효성
        const idHelp = document.getElementById('idHelp');
        const reId = /^[a-zA-Z0-9]{4,12}$/;
        function validateUsername() {
          const v = ids.username.value.trim();
          if (!v) { idHelp.textContent = '아이디를 입력하세요.'; idHelp.className = 'form-text invalid-msg'; return false; }
          if (!reId.test(v)) { idHelp.textContent = '영문/숫자 4~12자만 가능합니다.'; idHelp.className = 'form-text invalid-msg'; return false; }
          idHelp.textContent = '사용 가능한 형식입니다. 중복확인을 해주세요.'; idHelp.className = 'form-text valid-msg'; return true;
        }

        // 비밀번호 유효성
        const pw = ids.password, pw2 = ids.passwordConfirm;
        const pwHelp = document.getElementById('pwHelp'), ruleLen = document.getElementById('ruleLen'), ruleKinds = document.getElementById('ruleKinds');
        function countKinds(s) { let k = 0; if (/[A-Za-z]/.test(s)) k++; if (/[0-9]/.test(s)) k++; if (/[^A-Za-z0-9]/.test(s)) k++; return k; }
        function validatePassword() {
          const v = pw.value; const okLen = v.length >= 8 && v.length <= 20; const okKinds = countKinds(v) >= 2;
          ruleLen.className = okLen ? 'valid-msg' : 'invalid-msg'; ruleKinds.className = okKinds ? 'valid-msg' : 'invalid-msg';
          validatePwMatch(); return okLen && okKinds;
        }
        function validatePwMatch() {
          if (!pw.value && !pw2.value) { pwHelp.textContent = ''; pwHelp.className = 'form-text'; return false; }
          if (pw.value === pw2.value) { pwHelp.textContent = '비밀번호가 일치합니다.'; pwHelp.className = 'form-text valid-msg'; return true; }
          pwHelp.textContent = '비밀번호가 일치하지 않습니다.'; pwHelp.className = 'form-text invalid-msg'; return false;
        }

        // 이메일 코드 전송/확인
        async function sendEmailCode() {
          const email = document.getElementById('email').value.trim();
          if (!email) { alert('이메일을 입력하세요.'); return; }
          const btn = document.getElementById('btnSendCode'); btn.disabled = true;
          try {
            const res = await fetch('<%=ctx%>/email/send', { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' }, body: new URLSearchParams({ email }) });
            alert(await res.text());
          } catch (e) { alert('인증코드 전송 중 오류가 발생했습니다.'); } finally { btn.disabled = false; }
        }
        async function verifyEmailCode() {
          const email = document.getElementById('email').value.trim();
          const code = document.getElementById('emailCode').value.trim();
          if (!email || !code) { alert('이메일과 코드를 입력하세요.'); return; }
          const btn = document.getElementById('btnVerifyCode'); btn.disabled = true;
          try {
            const res = await fetch('<%=ctx%>/email/verify', { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' }, body: new URLSearchParams({ email, code }) });
            const json = await res.json().catch(() => ({ ok: false, msg: '응답 형식 오류' }));
            alert(json.msg || '처리되었습니다.');
            if (json.ok) {
              ids.emailVerified.value = '1';                 // ✅ 폼 안 hidden 값 세팅
              document.getElementById('email').readOnly = true;
              document.getElementById('emailCode').readOnly = true;
              document.getElementById('btnSendCode').disabled = true;
              document.getElementById('emailHidden').value = email; // 서버 전달용 이메일
              enableForm();
              updateRegisterButton();
            }
          } catch (e) { alert('인증 확인 중 오류가 발생했습니다.'); } finally { btn.disabled = false; }
        }

        // 아이디 중복확인
        async function checkIdDup() {
          if (!validateUsername()) { ids.username.focus(); return; }
          const username = ids.username.value.trim();
          const btn = ids.btnCheckDup; btn.disabled = true;
          try {
            const res = await fetch('<%=ctx%>/check_id?username=' + encodeURIComponent(username));
            const text = await res.text();
            try { const json = JSON.parse(text); alert(json.msg || (json.ok ? '사용 가능합니다.' : '이미 사용 중입니다.')); }
            catch (_) { alert(text); }
          } catch (e) { alert('중복확인 요청 실패: ' + (e?.message || e)); } finally { btn.disabled = false; }
        }

        function updateRegisterButton() {
          const emailOk = (ids.emailVerified.value === '1');
          const idOk = validateUsername();
          const pwOk = validatePassword();
          const matchOk = validatePwMatch();
          ids.btnRegister.disabled = !(emailOk && idOk && pwOk && matchOk && !!ids.name.value.trim());
        }

        ids.username.addEventListener('input', () => { validateUsername(); updateRegisterButton(); });
        ids.password.addEventListener('input', () => { validatePassword(); updateRegisterButton(); });
        ids.passwordConfirm.addEventListener('input', () => { validatePwMatch(); updateRegisterButton(); });
        ids.name.addEventListener('input', updateRegisterButton);

        function validateBeforeSubmit() {
          if (ids.emailVerified.value !== '1') { alert('이메일 인증을 먼저 완료하세요.'); return false; }
          if (!validateUsername()) { alert('아이디 형식을 확인하세요.'); ids.username.focus(); return false; }
          if (!validatePassword()) { alert('비밀번호 규칙을 충족해야 합니다.'); ids.password.focus(); return false; }
          if (!validatePwMatch()) { alert('비밀번호가 일치하지 않습니다.'); ids.passwordConfirm.focus(); return false; }
          if (!ids.name.value.trim()) { alert('이름을 입력하세요.'); ids.name.focus(); return false; }
          return true;
        }
      </script>
    </body>

    </html>