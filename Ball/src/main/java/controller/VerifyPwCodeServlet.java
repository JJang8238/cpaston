package controller;

import dao.UserDAO;
import dto.User;
import util.DBConnection;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@WebServlet("/pw/code/verify")
public class VerifyPwCodeServlet extends HttpServlet {

    private String json(boolean ok, String msg) {
        String safe = msg == null ? "" : msg.replace("\\", "\\\\")
                                           .replace("\"", "\\\"")
                                           .replace("\n", "\\n");
        return "{\"ok\":" + ok + ",\"msg\":\"" + safe + "\"}";
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");

        String username = req.getParameter("username");
        String email    = req.getParameter("email");
        String code     = req.getParameter("code");

        if (username == null || username.isBlank() ||
            email == null || email.isBlank() ||
            code == null || code.isBlank()) {

            resp.getWriter().write(json(false, "필드를 모두 입력하세요."));
            return;
        }

        // ---------------------------------------------------------
        // ✔ 1) email_verification 테이블에서 인증코드 확인
        // ---------------------------------------------------------
        try (Connection conn = DBConnection.getConnection()) {

            String sql = "SELECT code, expires_at FROM email_verification WHERE email=?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, email);

                try (ResultSet rs = ps.executeQuery()) {

                    if (!rs.next()) {
                        resp.getWriter().write(json(false, "인증코드를 먼저 전송하세요."));
                        return;
                    }

                    String savedCode = rs.getString("code");

                    LocalDateTime expiresAt = LocalDateTime.parse(
                        rs.getString("expires_at"),
                        DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")
                    );

                    if (LocalDateTime.now().isAfter(expiresAt)) {
                        resp.getWriter().write(json(false, "코드가 만료되었습니다."));
                        return;
                    }

                    if (!savedCode.equals(code)) {
                        resp.getWriter().write(json(false, "코드가 일치하지 않습니다."));
                        return;
                    }
                }
            }

        } catch (Exception e) {
            resp.setStatus(500);
            resp.getWriter().write(json(false, "DB 오류: " + e.getMessage()));
            return;
        }

        // ---------------------------------------------------------
        // ✔ 2) 아이디 + 이메일이 실제 등록된 유저인지 확인
        // ---------------------------------------------------------
        User user;
        try (UserDAO dao = new UserDAO()) {
            user = dao.findByUsernameAndEmail(username, email);
        }

        if (user == null) {
            resp.getWriter().write(json(false, "일치하는 회원이 없습니다."));
            return;
        }

        // ---------------------------------------------------------
        // ✔ 3) 성공 → 세션에 userId 저장 → 비밀번호 재설정 단계로 이동
        // ---------------------------------------------------------
        HttpSession session = req.getSession(true);
        session.setAttribute("pwResetUserId", user.getId());

        resp.getWriter().write(json(true, "인증 성공!"));
    }
}
