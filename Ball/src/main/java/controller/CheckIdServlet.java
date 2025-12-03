package controller;

import dao.UserDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet(name = "CheckIdServlet", urlPatterns = {"/check_id"})
public class CheckIdServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");

        String username = req.getParameter("username");
        if (username == null || username.isBlank()) {
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write("{\"ok\":false,\"msg\":\"아이디를 입력하세요.\"}");
            return;
        }

        try {
            UserDAO dao = new UserDAO();
            boolean available = dao.isAvailable(username);

            resp.setContentType("application/json; charset=UTF-8");
            if (available) {
                resp.getWriter().write("{\"ok\":true,\"msg\":\"사용 가능한 아이디입니다.\"}");
            } else {
                resp.getWriter().write("{\"ok\":false,\"msg\":\"이미 사용 중인 아이디입니다.\"}");
            }
        } catch (Throwable t) {
            // 디버깅을 위해 에러 원문을 반환
            resp.setStatus(500);
            resp.setContentType("text/plain; charset=UTF-8");
            resp.getWriter().println("[/check_id] 오류:");
            resp.getWriter().println(t.getClass().getName() + ": " + String.valueOf(t.getMessage()));
            for (StackTraceElement e : t.getStackTrace()) {
                resp.getWriter().println("  at " + e.toString());
            }
        }
    }

    // POST로 호출해도 동작하도록
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        doGet(req, resp);
    }
}
