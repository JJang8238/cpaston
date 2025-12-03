<%@ page import="java.sql.*, dao.UserDAO" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
request.setCharacterEncoding("UTF-8");

// 본인인증 체크
Boolean authVerified = (Boolean) session.getAttribute("auth_verified");
if (authVerified == null || !authVerified) {
%>
    <script>
        alert("본인인증을 먼저 완료해주세요.");
        history.back();
    </script>
<%
    return;
}

// 폼 파라미터 받기
String username = request.getParameter("username");
String password = request.getParameter("password");
String name     = request.getParameter("name");
String email    = request.getParameter("email");   // ★ 추가됨 ★

// 회원가입 처리
UserDAO dao = new UserDAO();
boolean success = dao.registerUser(username, password, name, email);

if (success) {
    // 가입 완료 시 세션 초기화
    session.removeAttribute("auth_verified");
    session.removeAttribute("auth_name");
    session.removeAttribute("auth_phone");
    session.removeAttribute("auth_birth");

    response.sendRedirect("login.jsp");
} else {
%>
    <script>
        alert("회원가입 실패. 아이디 또는 이메일이 중복되었거나 오류가 발생했습니다.");
        history.back();
    </script>
<%
}
%>