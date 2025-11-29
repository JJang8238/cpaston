<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%
    String ctx = request.getContextPath();
%>

<%@ include file="include/header.jsp" %>

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
        display: flex;
        justify-content: center;
        align-items: flex-start;
        padding-top: 40px;
    }

    /* 제목 */
    .signup-title {
        text-align: center;
        font-size: 32px;
        font-weight: 700;
        margin-top: 40px;
        margin-bottom: 30px;
    }

    /* 전체 래퍼 */
    .signup-wrapper {
        width: 100%;
        max-width: 720px;
        margin: 0 auto;
        display: flex;
        flex-direction: column;
        align-items: center; 
    }

    /* 카드 디자인 – 간격 크게 줄임 */
    .form-card {
        width: 100%;
        background: #ffffff;
        padding: 32px 28px;
        border-radius: 16px;
        margin-bottom: 16px;   /* 👈 기존 32px → 16px 로 변경 */
        box-shadow: 0 8px 26px rgba(0,0,0,0.08);
    }

    /* 라벨 */
    .form-label {
        font-weight: 600;
        color: #333;
    }

    /* 인풋 */
    .form-control {
        height: 48px;
        font-size: 15px;
        border-radius: 10px;
        background-color: #eef4ff;
    }
    .form-control:focus {
        border-color: #2BAE66;
        box-shadow: 0 0 0 3px rgba(43,174,102,0.15);
    }

    .input-group .form-control {
        border-top-right-radius: 0 !important;
        border-bottom-right-radius: 0 !important;
    }
    .input-group .btn {
        border-top-left-radius: 0 !important;
        border-bottom-left-radius: 0 !important;
        height: 48px;
        font-size: 14px;
        font-weight: 600;
        border-color: #c7d8ff;
    }

    .badge-auth {
        font-size: 17px;
        padding: 11px 22px;
        border-radius: 12px;
    }

    .btn-success {
        height: 48px;
        background: #2BAE66;
        border: none;
        font-size: 17px;
        font-weight: 600;
        border-radius: 10px;
    }
    .btn-success:hover {
        background: #239956;
    }

    .valid-msg { color: #2BAE66 !important; font-weight: 600; }
    .invalid-msg { color: #dc3545 !important; font-weight: 600; }

    .eye-btn {
        width: 46px;
        font-size: 18px;
    }

    /* 모바일 */
    @media (max-width: 576px) {
        .signup-title {
            font-size: 26px;
            margin-top: 24px;
            margin-bottom: 20px;
        }
        .form-card {
            padding: 24px 18px;
            margin-bottom: 12px;   /* 모바일에서도 간격 줄임 */
        }
    }
</style>

<main>
    <div class="container py-5">
        <div class="signup-wrapper">

            <h2 class="signup-title">회원가입</h2>

            <!-- 이메일 인증 카드 -->
            <div class="form-card">
                <div class="text-center mb-3">
                    <span class="badge text-bg-primary badge-auth">이메일 본인인증</span>
                </div>

                <div class="mb-3">
                    <label class="form-label">이메일</label>
                    <div class="input-group">
                        <input type="email" id="email" class="form-control" placeholder="you@example.com" required>
                        <button class="btn btn-outline-secondary" id="btnSendCode" type="button"
                                onclick="sendEmailCode()">인증코드 보내기</button>
                    </div>
                    <div class="form-text">메일함(스팸함 포함)을 확인하세요. 코드는 10분간 유효합니다.</div>
                </div>

                <div class="mb-1">
                    <label class="form-label">이메일 인증코드</label>
                    <div class="input-group">
                        <input type="text" id="emailCode" class="form-control" maxlength="6" placeholder="6자리">
                        <button class="btn btn-primary" id="btnVerifyCode" type="button"
                                onclick="verifyEmailCode()">코드 확인</button>
                    </div>
                </div>
            </div>

            <!-- 회원가입 입력 카드 -->
            <div class="form-card">
                <form action="<%=ctx%>/register" method="post" onsubmit="return validateBeforeSubmit();">

                    <input type="hidden" id="emailVerified" name="emailVerified" value="0">
                    <input type="hidden" id="emailHidden" name="email">

                    <div class="mb-3">
                        <label class="form-label">아이디</label>
                        <div class="input-group">
                            <input type="text" class="form-control"
                                   id="username" name="username" minlength="4" maxlength="12"
                                   disabled placeholder="영문/숫자 4~12자">
                            <button class="btn btn-outline-secondary" id="btnCheckDup" type="button"
                                    disabled onclick="checkIdDup()">중복확인</button>
                        </div>
                        <div id="idHelp" class="form-text">영문/숫자 4~12자</div>
                    </div>

                    <!-- 비밀번호 -->
                    <div class="mb-3">
                        <label class="form-label">비밀번호</label>
                        <div class="input-group">
                            <input type="password" class="form-control" id="password" name="password"
                                   disabled minlength="8" maxlength="20"
                                   placeholder="8~20자, 영문/숫자/특수문자 2종 이상">
                            <button class="btn btn-outline-secondary eye-btn" type="button"
                                    onclick="toggleEye('password')">👁</button>
                        </div>
                        <ul class="small mb-0 mt-1">
                            <li id="ruleLen" class="text-muted">길이 8~20자</li>
                            <li id="ruleKinds" class="text-muted">문자 종류 2종 이상(영문/숫자/특수)</li>
                        </ul>
                    </div>

                    <!-- PW 확인 -->
                    <div class="mb-3">
                        <label class="form-label">비밀번호 확인</label>
                        <div class="input-group">
                            <input type="password" class="form-control" id="passwordConfirm"
                                   disabled minlength="8" maxlength="20" placeholder="비밀번호 재입력">
                            <button class="btn btn-outline-secondary eye-btn" type="button"
                                    onclick="toggleEye('passwordConfirm')">👁</button>
                        </div>
                        <div id="pwHelp" class="form-text"></div>
                    </div>

                    <!-- 이름 -->
                    <div class="mb-4">
                        <label class="form-label">이름</label>
                        <input type="text" class="form-control" id="name" name="name" disabled>
                    </div>

                    <button type="submit" id="btnRegister" class="btn btn-success w-100" disabled>가입하기</button>

                </form>
            </div>

        </div>
    </div>
</main>

<script>
    const ids = {
        username: document.getElementById('username'),
        btnCheckDup: document.getElementById('btnCheckDup'),
        password: document.getElementById('password'),
        passwordConfirm: document.getElementById('passwordConfirm'),
        name: document.getElementById('name'),
        btnRegister: document.getElementById('btnRegister'),
        emailVerified: document.getElementById('emailVerified')
    };

    function setDisabled(d){
        ['username','btnCheckDup','password','passwordConfirm','name','btnRegister']
            .forEach(id=>{
                const el=document.getElementById(id);
                if(el) el.disabled=d;
            });
    }
    function enableForm(){ setDisabled(false); }

    function toggleEye(id){
        const el=document.getElementById(id);
        el.type = (el.type==='password' ? 'text':'password');
    }

    /* 아이디 검증 */
    const idHelp=document.getElementById('idHelp');
    const reId=/^[a-zA-Z0-9]{4,12}$/;
    function validateUsername(){
        const v=ids.username.value.trim();
        if(!v){ idHelp.textContent='아이디를 입력하세요.'; idHelp.className='form-text invalid-msg'; return false;}
        if(!reId.test(v)){ idHelp.textContent='영문/숫자 4~12자만 가능합니다.'; idHelp.className='form-text invalid-msg'; return false;}
        idHelp.textContent='사용 가능한 형식입니다. 중복확인을 해주세요.'; idHelp.className='form-text valid-msg'; return true;
    }

    /* 비밀번호 검증 */
    const pw=ids.password, pw2=ids.passwordConfirm;
    const pwHelp=document.getElementById('pwHelp'),
          ruleLen=document.getElementById('ruleLen'),
          ruleKinds=document.getElementById('ruleKinds');

    function countKinds(s){
        let k=0;
        if(/[A-Za-z]/.test(s))k++;
        if(/[0-9]/.test(s))k++;
        if(/[^A-Za-z0-9]/.test(s))k++;
        return k;
    }

    function validatePassword(){
        const v=pw.value;
        const okLen=v.length>=8&&v.length<=20;
        const okKinds=countKinds(v)>=2;
        ruleLen.className= okLen?'valid-msg':'invalid-msg';
        ruleKinds.className= okKinds?'valid-msg':'invalid-msg';
        validatePwMatch();
        return okLen&&okKinds;
    }

    function validatePwMatch(){
        if(!pw.value&&!pw2.value){
            pwHelp.textContent=''; pwHelp.className='form-text';
            return false;
        }
        if(pw.value===pw2.value){
            pwHelp.textContent='비밀번호가 일치합니다.'; pwHelp.className='form-text valid-msg';
            return true;
        }
        pwHelp.textContent='비밀번호가 일치하지 않습니다.'; pwHelp.className='form-text invalid-msg';
        return false;
    }

    /* 이메일 인증 */
    async function sendEmailCode(){
        const email=document.getElementById('email').value.trim();
        if(!email){ alert('이메일을 입력하세요.'); return; }

        const btn=document.getElementById('btnSendCode');
        btn.disabled=true;

        try{
            const res=await fetch('<%=ctx%>/email/send',{
                method:'POST',
                headers:{'Content-Type':'application/x-www-form-urlencoded;charset=UTF-8'},
                body:new URLSearchParams({email})
            });
            alert(await res.text());
        }catch(e){
            alert('인증코드 전송 중 오류 발생');
        }finally{
            btn.disabled=false;
        }
    }

    async function verifyEmailCode(){
        const email=document.getElementById('email').value.trim();
        const code=document.getElementById('emailCode').value.trim();
        if(!email||!code){
            alert('이메일과 코드를 입력하세요.');
            return;
        }

        const btn=document.getElementById('btnVerifyCode');
        btn.disabled=true;

        try{
            const res=await fetch('<%=ctx%>/email/verify',{
                method:'POST',
                headers:{'Content-Type':'application/x-www-form-urlencoded;charset=UTF-8'},
                body:new URLSearchParams({email,code})
            });

            const json=await res.json().catch(()=>({ok:false,msg:'응답 오류'}));
            alert(json.msg);

            if(json.ok){
                ids.emailVerified.value='1';
                document.getElementById('email').readOnly=true;
                document.getElementById('emailCode').readOnly=true;
                document.getElementById('btnSendCode').disabled=true;

                document.getElementById('emailHidden').value=email;

                enableForm();
                updateRegisterButton();
            }
        }catch(e){
            alert('인증 오류');
        }finally{
            btn.disabled=false;
        }
    }

    /* 아이디 중복확인 */
    async function checkIdDup(){
        if(!validateUsername()){
            ids.username.focus();
            return;
        }
        const username=ids.username.value.trim();
        const btn=ids.btnCheckDup;
        btn.disabled=true;

        try{
            const res=await fetch('<%=ctx%>/check_id?username=' + encodeURIComponent(username));
            const text=await res.text();
            try{
                const json=JSON.parse(text);
                alert(json.msg);
            }catch(_){
                alert(text);
            }
        }catch(e){
            alert('중복확인 실패');
        }finally{
            btn.disabled=false;
        }
    }

    /* 전체 버튼 활성화 여부 */
    function updateRegisterButton(){
        const emailOk=(ids.emailVerified.value==='1');
        const idOk=validateUsername();
        const pwOk=validatePassword();
        const matchOk=validatePwMatch();
        const nameOk=!!ids.name.value.trim();
        ids.btnRegister.disabled=!(emailOk&&idOk&&pwOk&&matchOk&&nameOk);
    }

    ids.username.addEventListener('input', ()=>{ validateUsername(); updateRegisterButton(); });
    ids.password.addEventListener('input', ()=>{ validatePassword(); updateRegisterButton(); });
    ids.passwordConfirm.addEventListener('input', ()=>{ validatePwMatch(); updateRegisterButton(); });
    ids.name.addEventListener('input', updateRegisterButton);

    function validateBeforeSubmit(){
        if(ids.emailVerified.value!=='1'){ alert('이메일 인증을 먼저 완료하세요.'); return false; }
        if(!validateUsername()){ alert('아이디 형식을 확인하세요.'); ids.username.focus(); return false; }
        if(!validatePassword()){ alert('비밀번호 규칙을 충족해야 합니다.'); ids.password.focus(); return false; }
        if(!validatePwMatch()){ alert('비밀번호가 일치하지 않습니다.'); ids.passwordConfirm.focus(); return false; }
        if(!ids.name.value.trim()){ alert('이름을 입력하세요.'); ids.name.focus(); return false; }
        return true;
    }
</script>

<%@ include file="include/footer.jsp" %>