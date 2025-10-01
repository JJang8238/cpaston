<%@ page import="java.sql.*, dao.UserDAO" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
request.setCharacterEncoding("UTF-8");

// 본인인증 체크
Boolean authVerified = (Boolean) session.getAttribute("auth_verified");
if (authVerified == null || !authVerified) {
    // 인증이 안된 경우 경고 후 이전 페이지로
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
String name = request.getParameter("name");

// 회원가입 처리
UserDAO dao = new UserDAO();
boolean success = dao.registerUser(username, password, name);

if (success) {
    // 가입 완료 시 세션 초기화 (auth_verified 등)
    session.removeAttribute("auth_verified");
    session.removeAttribute("auth_name");
    session.removeAttribute("auth_phone");
    session.removeAttribute("auth_birth");

    response.sendRedirect("login.jsp");
} else {
%>
    <script>
        alert("회원가입 실패. 아이디가 중복되었거나 오류가 발생했습니다.");
        history.back();
    </script>
<%
}
%>
