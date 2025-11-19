<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="dao.UserDAO" %>
<%@ page import="dto.User" %>
<%@ page import="util.LoginConst" %>
<%
    request.setCharacterEncoding("UTF-8");

    String username = request.getParameter("username");
    String password = request.getParameter("password");

    // 1) DB 로그인 먼저 시도
    UserDAO dao = null;
    User user = null;
    try {
        dao = new UserDAO();
        user = dao.login(username, password); // 기존 코드 유지
    } catch (Exception e) {
        // DB 오류가 나더라도 하드코딩 백업 루트로 진행
    } finally {
        try { if (dao != null) dao.close(); } catch (Exception ignore) {}
    }

    if (user != null) {
        // ✅ DB 성공: 기존 로직 그대로
        session.setAttribute("loginUser", user);
        response.sendRedirect("main.jsp");
        return;
    }

    // 2) DB 실패 시 하드코딩 계정 검사
    if (LoginConst.TEMP_ID.equals(username) && LoginConst.TEMP_PW.equals(password)) {
        try {
            // ✅ dto.User 인스턴스를 리플렉션으로 생성 (세터 유무 상관없이 안전)
            Class<?> userCls = Class.forName("dto.User");
            Object dummy = userCls.getDeclaredConstructor().newInstance();

            // 가능한 세터들만 있으면 채워넣기 (없어도 무관)
            try { userCls.getMethod("setUsername", String.class).invoke(dummy, LoginConst.TEMP_ID); } catch (Exception ignore) {}
            try { userCls.getMethod("setName",     String.class).invoke(dummy, "임시 관리자"); } catch (Exception ignore) {}
            try { userCls.getMethod("setEmail",    String.class).invoke(dummy, "admin@example.com"); } catch (Exception ignore) {}
            try { userCls.getMethod("setRole",     String.class).invoke(dummy, "ADMIN"); } catch (Exception ignore) {}

            // 세션에는 dto.User 타입 객체가 들어가므로 main.jsp의 (User) 캐스팅이 안전함
            session.setAttribute("loginUser", dummy);
        } catch (Exception e) {
            // 혹시 dto.User 생성이 실패했을 때의 최후 fallback
            // (main.jsp에서 User로 캐스팅한다면 이 경우는 피하는 게 좋음)
            session.setAttribute("loginUser", username);
        }

        response.sendRedirect("main.jsp");
        return;
    }

    // 3) 둘 다 실패 → 에러 알림
    out.println("<script>");
    out.println("alert('로그인 실패. 아이디 또는 비밀번호를 확인해주세요.');");
    out.println("history.back();");
    out.println("</script>");
%>