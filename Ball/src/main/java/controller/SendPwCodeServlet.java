package controller;

import dao.UserDAO;
import dto.User;
import util.DBConnection;
import util.EmailUtil;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Random;

@WebServlet("/pw/code/send")
public class SendPwCodeServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/plain; charset=UTF-8");

        String username = req.getParameter("username");
        String email = req.getParameter("email");

        if (username == null || username.isBlank() ||
            email == null || email.isBlank()) {
            resp.setStatus(400);
            resp.getWriter().println("아이디와 이메일을 모두 입력하세요.");
            return;
        }

        // ------------------------------------------------
        // ✔ 1) 아이디 + 이메일이 맞는지 확인
        // ------------------------------------------------
        User user;
        try (UserDAO dao = new UserDAO()) {
            user = dao.findByUsernameAndEmail(username, email);
        }

        if (user == null) {
            resp.setStatus(404);
            resp.getWriter().println("일치하는 회원 정보가 없습니다.");
            return;
        }

        // ------------------------------------------------
        // ✔ 2) 인증코드 생성 + email_verification 테이블에 저장
        // ------------------------------------------------
        String code = String.format("%06d", new Random().nextInt(1_000_000));
        String expiresStr = LocalDateTime.now()
                .plusMinutes(10)
                .format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "INSERT INTO email_verification (email, code, expires_at, attempts) " +
                         "VALUES (?, ?, ?, 0) " +
                         "ON DUPLICATE KEY UPDATE code=?, expires_at=?, attempts=0";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, email);
                ps.setString(2, code);
                ps.setString(3, expiresStr);
                ps.setString(4, code);
                ps.setString(5, expiresStr);
                ps.executeUpdate();
            }
        } catch (Exception e) {
            resp.setStatus(500);
            resp.getWriter().println("DB 오류: " + e.getMessage());
            return;
        }

        // ------------------------------------------------
        // ✔ 3) 이메일 발송
        // ------------------------------------------------
        try {
            String body = "플랩풋볼 비밀번호 찾기 인증코드: " + code + "\n\n10분간 유효합니다.";
            EmailUtil.sendText(email, "[플랩풋볼] 비밀번호 찾기 인증코드", body);

            resp.getWriter().println("인증코드가 이메일로 전송되었습니다.");

        } catch (Exception e) {
            resp.setStatus(500);
            resp.getWriter().println("메일 전송 실패: " + e.getMessage());
        }
    }
}
