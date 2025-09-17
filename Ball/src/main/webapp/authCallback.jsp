<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    request.setCharacterEncoding("UTF-8");

    String name  = request.getParameter("name");
    String phone = request.getParameter("phone");
    String birth = request.getParameter("birth");

    // 실제 토스 연동 시엔 여기서 secretKey로 서버-서버 검증 로직이 들어감(모의이므로 생략)
    session.setAttribute("auth_verified", true);
    session.setAttribute("auth_name",  name);
    session.setAttribute("auth_phone", phone);
    session.setAttribute("auth_birth", birth);

    // 팝업에서 열렸다면 부모 창을 새로고침하고 닫기
%>
<script>
    if (window.opener) {
        window.opener.location.href = "register.jsp";
        window.close();
    } else {
        // 팝업이 아니라면 그냥 redirect
        location.href = "register.jsp";
    }
</script>
