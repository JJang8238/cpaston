package controller;

import dao.MatchDAO;
import dto.Match;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;

@WebServlet("/matchController")
public class MatchController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        doPost(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        MatchDAO dao = new MatchDAO();

        try {

            /* ==========================================================
                1) 경기 생성
            ========================================================== */
            if ("create".equals(action)) {

                Match m = new Match();
                m.setLocation(req.getParameter("place"));
                m.setMatchDate(LocalDate.parse(req.getParameter("date")));
                m.setMatchTime(LocalTime.parse(req.getParameter("time")));
                m.setMaxPlayers(Integer.parseInt(req.getParameter("max")));

                dao.createMatch(m);

                resp.sendRedirect(req.getContextPath() + "/admin/admin_menu.jsp?page=match");
            }

            /* ==========================================================
                2) 경기 수정 — 로그 추가
            ========================================================== */
            else if ("update".equals(action)) {

                String idStr = req.getParameter("id");
                String place = req.getParameter("place");
                String dateStr = req.getParameter("date");
                String timeStr = req.getParameter("time");
                String maxStr = req.getParameter("max");

                // 🔥 디버그 로그 출력
                System.out.println("\n========== [UPDATE 요청 값] ==========");
                System.out.println("id   = " + idStr);
                System.out.println("place= " + place);
                System.out.println("date = " + dateStr);
                System.out.println("time = " + timeStr);
                System.out.println("max  = " + maxStr);
                System.out.println("====================================\n");

                Match m = new Match();
                m.setId(Integer.parseInt(idStr));
                m.setLocation(place);
                m.setMatchDate(LocalDate.parse(dateStr));
                m.setMatchTime(LocalTime.parse(timeStr));
                m.setMaxPlayers(Integer.parseInt(maxStr));

                boolean result = dao.updateMatch(m);

                // 🔥 UPDATE 결과 로그
                System.out.println("UPDATE SQL 결과 → " + result);

                resp.sendRedirect(req.getContextPath() + "/admin/admin_menu.jsp?page=match");
            }

            /* ==========================================================
                3) 경기 삭제
            ========================================================== */
            else if ("delete".equals(action)) {

                int id = Integer.parseInt(req.getParameter("id"));
                dao.deleteMatch(id);

                resp.sendRedirect(req.getContextPath() + "/admin/admin_menu.jsp?page=match");
            }

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/admin/admin_menu.jsp?page=match&error=1");
        } finally {
            dao.close();
        }
    }
}
