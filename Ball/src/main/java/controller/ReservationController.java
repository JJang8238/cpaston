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

    /* ============================================================
       GET : 경기 불러오기 / 리뷰 작성 가능 여부 확인
       ============================================================ */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        String action = request.getParameter("action");
        String place  = request.getParameter("place");
        String date   = request.getParameter("date");

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loginUser") : null;

        int userId = (user != null) ? user.getId() : -1;

        /* 🔥 MatchDAO는 반드시 요청마다 새로 생성 */
        try (MatchDAO matchDAO = new MatchDAO()) {

            /* -----------------------------------------------------------
                1) 장소 기준 일정 조회
            ----------------------------------------------------------- */
            if ("matchesByPlace".equals(action) && place != null) {

                List<Match> matches = matchDAO.getMatchesByPlace(place, date);
                JsonArray arr = new JsonArray();

                for (Match m : matches) {
                    JsonObject obj = new JsonObject();

                    obj.addProperty("id", m.getId());
                    obj.addProperty("time", (m.getMatchTime() != null) ? m.getMatchTime().toString() : "");
                    obj.addProperty("current", m.getCurrentPlayers());
                    obj.addProperty("max", m.getMaxPlayers());
                    obj.addProperty("canceled", "취소됨".equals(m.getMatchStatus()));
                    obj.addProperty("joined", userId != -1 && matchDAO.isUserReserved(userId, m.getId()));

                    arr.add(obj);
                }

                response.getWriter().write(arr.toString());
                return;
            }

            /* -----------------------------------------------------------
                2) 리뷰 작성 가능 여부
            ----------------------------------------------------------- */
            else if ("canReview".equals(action) && place != null) {

                JsonObject result = new JsonObject();

                if (userId == -1) {
                    result.addProperty("can", false);
                    response.getWriter().write(result.toString());
                    return;
                }

                List<Match> matches = matchDAO.getMatchesByPlace(place, date);
                boolean can = false;

                for (Match m : matches) {
                    if (matchDAO.isUserReserved(userId, m.getId())) {
                        can = true;
                        break;
                    }
                }

                result.addProperty("can", can);
                response.getWriter().write(result.toString());
                return;
            }

            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        }
    }



    /* ============================================================
       POST : 예약 / 취소
       ============================================================ */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("loginUser") : null;

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = user.getId();
        int matchId = Integer.parseInt(request.getParameter("matchId"));

        boolean isAjax = "XMLHttpRequest".equals(request.getHeader("X-Requested-With"));

        /* 🔥 여기에서도 MatchDAO는 매 요청마다 새 객체 */
        try (MatchDAO matchDAO = new MatchDAO();
             PrintWriter out = response.getWriter()) {

            response.setContentType("application/json; charset=UTF-8");

            /* ---------------------------------------------------------
                1) 예약하기
            --------------------------------------------------------- */
            if ("book".equals(action)) {

                boolean ok = matchDAO.bookMatch(userId, matchId);
                out.write("{\"ok\":" + ok + "}");
                return;
            }

            /* ---------------------------------------------------------
                2) 예약 취소
            --------------------------------------------------------- */
            else if ("cancel".equals(action)) {

                boolean ok = matchDAO.cancelReservation(userId, matchId);

                // form 제출 (마이페이지)
                if (!isAjax) {
                    session.setAttribute("msg", ok ? "예약이 취소되었습니다." : "예약 취소 실패!");
                    response.sendRedirect("mypage.jsp");
                    return;
                }

                // AJAX
                out.write("{\"ok\":" + ok + "}");
                return;
            }

            /* ---------------------------------------------------------
                3) 잘못된 action
            --------------------------------------------------------- */
            else {
                out.write("{\"ok\":false,\"msg\":\"올바르지 않은 요청입니다.\"}");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
