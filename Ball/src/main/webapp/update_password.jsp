<%@ page import="dao.UserDAO" %>
<%@ page import="dto.User" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    request.setCharacterEncoding("UTF-8");

    User resetUser = (User) session.getAttribute("resetUser");
    if (resetUser == null) {
        response.sendRedirect("find_pw.jsp");
        return;
    }

    String pw1 = request.getParameter("password1");
    String pw2 = request.getParameter("password2");

    if (!pw1.equals(pw2)) {
%>
<script>
    alert("비밀번호가 일치하지 않습니다.");
    history.back();
</script>
<%
        return;
    }

    try (UserDAO dao = new UserDAO()) {
        dao.updatePassword(resetUser.getId(), pw1);   // ★ 수정됨! (username X → id O)
    }

    session.removeAttribute("resetUser");
%>

<script>
    alert("비밀번호가 성공적으로 변경되었습니다!");
    location.href="login.jsp";
</script>
