package controller;

import dao.ReservationDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/reserve")
public class ReserveServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");

        String action = req.getParameter("action");   // book or cancel
        int matchId   = Integer.parseInt(req.getParameter("matchId"));

        // 🔸 임시: 로그인 유저 ID = 1 (나중에 세션 값으로 교체)
        HttpSession session = req.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) userId = 1;

        ReservationDAO dao = new ReservationDAO();
        ReservationDAO.BookResult result =
            "book".equals(action)   ? dao.book(userId, matchId) :
            "cancel".equals(action) ? dao.cancel(userId, matchId) :
            new ReservationDAO.BookResult(false, "bad_request", -1);

        String json = String.format("{\"ok\":%s,\"msg\":\"%s\",\"current\":%d}",
                result.ok, result.msg, result.currentPlayers);

        resp.getWriter().write(json);
    }
}
