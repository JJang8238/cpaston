<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.UserDAO" %>
<%@ page import="dto.User" %>

<%
    request.setCharacterEncoding("UTF-8");
    String username = request.getParameter("username");
    String password = request.getParameter("password");

    UserDAO dao = new UserDAO();
    User user = dao.login(username, password);

    if (user != null) {
        session.setAttribute("loginUser", user);
        response.sendRedirect("main.jsp"); // ✅ 여기 반드시 main.jsp여야 해!
    } else {
        out.println("<script>");
        out.println("alert('로그인 실패. 아이디 또는 비밀번호를 확인해주세요.');");
        out.println("history.back();");
        out.println("</script>");
    }
%>
