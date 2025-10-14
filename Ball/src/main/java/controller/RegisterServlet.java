package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private void alert(HttpServletResponse resp, String msg) throws IOException {
        resp.setContentType("text/html; charset=UTF-8");
        PrintWriter out = resp.getWriter();
        out.println("<script>alert('" + msg.replace("'", "\\'") + "'); history.back();</script>");
    }

    private void alertAndRedirect(HttpServletResponse resp, String msg, String to) throws IOException {
        resp.setContentType("text/html; charset=UTF-8");
        PrintWriter out = resp.getWriter();
        out.println("<script>alert('" + msg.replace("'", "\\'") + "'); location.href='" + to + "';</script>");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String name     = req.getParameter("name");
        String email    = req.getParameter("email");
        String emailVerified = req.getParameter("emailVerified"); // "1"이어야 함

        // 서버측: 이메일 인증 확인
        HttpSession session = req.getSession(false);
        String verifiedEmail = (session == null) ? null : (String) session.getAttribute("verifiedEmail");
        if (!"1".equals(emailVerified) || verifiedEmail == null || !verifiedEmail.equals(email)) {
            alert(resp, "이메일 인증을 먼저 완료하세요.");
            return;
        }

        // 간단 유효성 (프론트와 동일 규칙의 최소 버전)
        if (username == null || !username.matches("^[a-zA-Z0-9]{4,12}$")) {
            alert(resp, "아이디 형식이 올바르지 않습니다.");
            return;
        }
        if (password == null || password.length() < 8 || password.length() > 20) {
            alert(resp, "비밀번호 길이는 8~20자여야 합니다.");
            return;
        }
        int kinds = 0;
        if (password.matches(".*[A-Za-z].*")) kinds++;
        if (password.matches(".*\\d.*")) kinds++;
        if (password.matches(".*[^A-Za-z0-9].*")) kinds++;
        if (kinds < 2) {
            alert(resp, "비밀번호는 영문/숫자/특수문자 중 2종 이상을 포함해야 합니다.");
            return;
        }
        if (name == null || name.isBlank()) {
            alert(resp, "이름을 입력하세요.");
            return;
        }

        try {
            UserDAO userDAO = new UserDAO();
            // 이메일 포함 가입 메서드 사용
            boolean ok = userDAO.registerUser(username, password, name, email);

            if (ok) {
                if (session != null) session.removeAttribute("verifiedEmail");
                // ✅ 성공: 팝업 후 로그인 페이지로 이동
                alertAndRedirect(resp, "회원가입 완료되었습니다!", req.getContextPath() + "/login.jsp");
            } else {
                alert(resp, "회원가입 실패. 이미 존재하는 아이디/이메일일 수 있습니다.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            alert(resp, "회원가입 처리 중 오류가 발생했습니다.");
        }
    }
}