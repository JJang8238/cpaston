<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="dao.UserDAO" %>
<%@ page import="dto.User" %>
<%@ page import="util.LoginConst" %>
<%
    request.setCharacterEncoding("UTF-8");

    String username = request.getParameter("username");
    String password = request.getParameter("password");

    UserDAO dao = null;
    User user = null;

    try {
        dao = new UserDAO();
        user = dao.login(username, password);
    } catch (Exception e) {
    } finally {
        try { if (dao != null) dao.close(); } catch (Exception ignore) {}
    }

    /* ---------------------------
       1) DB 로그인 성공
       --------------------------- */
    if (user != null) {

        session.setAttribute("loginUser", user);

        // ⭐ 관리자 판별 후 분기
        if ("admin".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect("admin/admin_main.jsp");   // 관리자 페이지
        } else {
            response.sendRedirect("main.jsp");               // 일반 사용자 페이지
        }
        return;
    }

    /* ---------------------------
       2) 하드코딩 관리자 계정
       --------------------------- */
    if (LoginConst.TEMP_ID.equals(username) && LoginConst.TEMP_PW.equals(password)) {
        try {
            Class<?> userCls = Class.forName("dto.User");
            Object dummy = userCls.getDeclaredConstructor().newInstance();

            try { userCls.getMethod("setUsername", String.class).invoke(dummy, LoginConst.TEMP_ID); } catch (Exception ignore) {}
            try { userCls.getMethod("setName",     String.class).invoke(dummy, "임시 관리자"); } catch (Exception ignore) {}
            try { userCls.getMethod("setEmail",    String.class).invoke(dummy, "admin@example.com"); } catch (Exception ignore) {}
            try { userCls.getMethod("setRole",     String.class).invoke(dummy, "admin"); } catch (Exception ignore) {}

            session.setAttribute("loginUser", dummy);

        } catch (Exception e) {
            session.setAttribute("loginUser", username);
        }

        // ⭐ 하드코딩 관리자도 관리자 페이지로 이동
        response.sendRedirect("admin/admin_main.jsp");
        return;
    }

    /* ---------------------------
       3) 로그인 실패
       --------------------------- */
    out.println("<script>");
    out.println("alert('로그인 실패. 아이디 또는 비밀번호를 확인해주세요.');");
    out.println("history.back();");
    out.println("</script>");
%>