package controller;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import dao.MatchDAO;
import dto.Match;
import dto.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/reserve")
public class ReservationController extends HttpServlet {

    private final MatchDAO matchDAO = new MatchDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        String action = request.getParameter("action");
        String place  = request.getParameter("place");
        String date   = request.getParameter("date");   // 🔥 추가: 날짜(YYYY-MM-DD) 파라미터

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loginUser") : null;
        int userId = (user != null) ? user.getId() : -1;

        /* -------------------------------------------------------
            1) 해당 장소 기준으로 경기 일정 불러오기
               - date가 없으면 오늘 기준
               - date가 있으면 해당 날짜 기준
        ------------------------------------------------------- */
        if ("matchesByPlace".equals(action) && place != null) {

            List<Match> matches = matchDAO.getMatchesByPlace(place, date);
            JsonArray arr = new JsonArray();

            for (Match m : matches) {
                JsonObject obj = new JsonObject();

                obj.addProperty("id", m.getId());
                obj.addProperty("time", m.getMatchTime() != null ? m.getMatchTime().toString() : "");
                obj.addProperty("current", m.getCurrentPlayers());
                obj.addProperty("max", m.getMaxPlayers());
                obj.addProperty("canceled", "취소됨".equals(m.getMatchStatus()));
                obj.addProperty("joined", userId != -1 && matchDAO.isUserReserved(userId, m.getId()));

                arr.add(obj);
            }

            PrintWriter out = response.getWriter();
            out.write(arr.toString());
            out.flush();
            return;
        }

        /* -------------------------------------------------------
            2) 리뷰 작성 가능 여부 확인
               → 해당 장소 + 날짜의 경기 중 사용자가 예약한 적 있으면 true
               → date 없으면 오늘 기준
        ------------------------------------------------------- */
        else if ("canReview".equals(action) && place != null) {

            JsonObject result = new JsonObject();

            if (userId == -1) {
                // 로그인 안한 경우
                result.addProperty("can", false);
                PrintWriter out = response.getWriter();
                out.write(result.toString());
                return;
            }

            // 해당 장소 + 날짜의 경기 목록
            List<Match> matches = matchDAO.getMatchesByPlace(place, date);

            boolean can = false;
            for (Match m : matches) {
                if (matchDAO.isUserReserved(userId, m.getId())) {
                    can = true;
                    break;
                }
            }

            result.addProperty("can", can);

            PrintWriter out = response.getWriter();
            out.write(result.toString());
            return;
        }

        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
    }

    /* -------------------------------------------------------
        POST: 예약 처리 (예약/취소)
    ------------------------------------------------------- */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        PrintWriter out = response.getWriter();
        String action = request.getParameter("action");

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loginUser") : null;

        // 로그인되어 있어야 예약 가능
        if (user == null) {
            out.write("{\"ok\":false,\"msg\":\"로그인이 필요합니다.\"}");
            return;
        }

        int userId = user.getId();

        try {
            int matchId = Integer.parseInt(request.getParameter("matchId"));

            if ("book".equals(action)) {
                boolean ok = matchDAO.bookMatch(userId, matchId);
                String place = matchDAO.getPlaceByMatchId(matchId);
                out.write("{\"ok\":" + ok + ",\"place\":\"" + place + "\"}");
            }
            else if ("cancel".equals(action)) {
                boolean ok = matchDAO.cancelReservation(userId, matchId);
                String place = matchDAO.getPlaceByMatchId(matchId);
                out.write("{\"ok\":" + ok + ",\"place\":\"" + place + "\"}");
            }
            else {
                out.write("{\"ok\":false,\"msg\":\"올바르지 않은 요청입니다.\"}");
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"ok\":false,\"msg\":\"예외가 발생했습니다.\"}");
        }
    }
}
