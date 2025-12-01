<%@ page import="dao.UserDAO" %>
<%@ page import="dto.User" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    request.setCharacterEncoding("UTF-8");

    String username = request.getParameter("username");
    String email = request.getParameter("email");

    User foundUser = null;

    try (UserDAO dao = new UserDAO()) {
        foundUser = dao.findByUsernameAndEmail(username, email);
    }

    if (foundUser != null) {
        session.setAttribute("resetUser", foundUser);  // 임시 저장
        response.sendRedirect("new_password.jsp");
        return;
    }
%>

<script>
    alert("입력한 정보와 일치하는 계정이 없습니다.");
    history.back();
</script>
