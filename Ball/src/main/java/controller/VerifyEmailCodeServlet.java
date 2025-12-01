package controller;

import util.DBConnection;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@WebServlet("/email/verify")
public class VerifyEmailCodeServlet extends HttpServlet {

    private static String json(boolean ok, String msg) {
        // JSON 안전 이스케이프 (쌍따옴표 등)
        String safe = msg == null ? "" : msg.replace("\\", "\\\\")
                                           .replace("\"", "\\\"")
                                           .replace("\n", "\\n")
                                           .replace("\r", "\\r");
        return "{\"ok\":" + ok + ",\"msg\":\"" + safe + "\"}";
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");

        String email = req.getParameter("email");
        String code  = req.getParameter("code");

        // 1) 입력 검증
        if (email == null || email.isBlank() || code == null || code.isBlank()) {
            resp.setStatus(400);
            resp.getWriter().write(json(false, "이메일/코드를 입력하세요."));
            return;
        }

        // 2) DB에서 코드/만료시간 확인
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

            // 3) 성공 → 세션에 인증 이메일 저장
            HttpSession session = req.getSession(true);
            session.setAttribute("verifiedEmail", email);
            resp.getWriter().write(json(true, "이메일 인증 완료!"));

        } catch (Exception e) {
            e.printStackTrace(); // 서버 로그
            resp.setStatus(500);
            resp.getWriter().write(json(false, "오류: " + e.getMessage()));
        }
    }
}