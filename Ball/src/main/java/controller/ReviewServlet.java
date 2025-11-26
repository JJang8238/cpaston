package controller;

import dao.MatchReviewDAO;
import dao.PlaceReviewDAO;
import dao.ReviewDAO;
import dto.User;
import dto.Review;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import com.google.gson.Gson;

@WebServlet("/review")
public class ReviewServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        resp.setContentType("application/json; charset=UTF-8");

        String action = req.getParameter("action");

        // -------------------------------
        // 장소별 리뷰 목록
        // -------------------------------
        if ("listByPlace".equals(action)) {

            String place = req.getParameter("place");

            List<Map<String, Object>> list;
            try (PlaceReviewDAO dao = new PlaceReviewDAO()) {
                list = dao.listByPlace(place);
            }

            // 평균 평점 계산
            double sum = 0;
            int cnt = 0;
            for (Map<String, Object> r : list) {
                Object ratingObj = r.get("rating");
                if (ratingObj != null) {
                    sum += ((Number) ratingObj).doubleValue();
                    cnt++;
                }
            }

            double avg = (cnt == 0 ? 0 : sum / cnt);

            // JSON 반환
            String json =
                    "{"
                            + "\"avgRating\":" + String.format("%.1f", avg) + ","
                            + "\"count\":" + list.size() + ","
                            + "\"reviews\":" + toJson(list)
                            + "}";

            resp.getWriter().print(json);
            return;
        }

        // -------------------------------
        // 경기별 리뷰 목록
        // -------------------------------
        else if ("listByMatch".equals(action)) {

            int matchId = Integer.parseInt(req.getParameter("matchId"));
            List<Map<String, Object>> list = new MatchReviewDAO().listByMatch(matchId);

            resp.getWriter().print(toJson(list));
            return;
        }

        resp.getWriter().print("[]");
    }


    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");

        String action = req.getParameter("action");
        HttpSession session = req.getSession();

        User loginUser = (User) session.getAttribute("loginUser");
        if (loginUser == null) {
            resp.getWriter().print("{\"ok\":false, \"message\":\"login\"}");
            return;
        }

        int userId = loginUser.getId();
        boolean isAdmin = "admin".equals(loginUser.getRole());
        boolean ok = false;

        // -------------------------------
        // 장소 리뷰 추가
        // -------------------------------
        if ("add".equals(action) || "addByPlace".equals(action)) {

            String placeName = req.getParameter("place");
            Integer rating = parseInt(req.getParameter("rating"));
            String content = req.getParameter("content");

            ok = new PlaceReviewDAO().add(userId, placeName, rating, content);
            resp.getWriter().print("{\"ok\":" + ok + "}");
            return;
        }

        // -------------------------------
        // 경기 리뷰 추가
        // -------------------------------
        else if ("addByMatch".equals(action)) {

            int matchId = Integer.parseInt(req.getParameter("matchId"));
            Integer rating = parseInt(req.getParameter("rating"));
            String content = req.getParameter("content");

            ok = new MatchReviewDAO().add(userId, matchId, rating, content);
            resp.getWriter().print("{\"ok\":" + ok + "}");
            return;
        }

        // -------------------------------
        // 장소 리뷰 수정
        // -------------------------------
        else if ("update".equals(action) || "updateByPlace".equals(action)) {

            int reviewId = Integer.parseInt(req.getParameter("id"));
            Integer rating = parseInt(req.getParameter("rating"));
            String content = req.getParameter("content");

            ok = new PlaceReviewDAO().update(
                    reviewId, userId,
                    rating != null ? rating : 0,
                    content
            );
            resp.getWriter().print("{\"ok\":" + ok + "}");
            return;
        }

        // -------------------------------
        // 장소 리뷰 삭제 (유저 vs 관리자)
        // -------------------------------
        else if ("delete".equals(action) || "deleteByPlace".equals(action)) {

            int reviewId = Integer.parseInt(req.getParameter("id"));

            PlaceReviewDAO dao = new PlaceReviewDAO();

            if (isAdmin) {
                ok = dao.adminDelete(reviewId);
            } else {
                ok = dao.delete(reviewId, userId);
            }

            resp.getWriter().print("{\"ok\":" + ok + "}");
            return;
        }

        // -------------------------------
        // 구(旧) ReviewDAO 방식 (호환용)
        // -------------------------------
        else if (req.getParameter("placeName") != null) {

            String placeName = req.getParameter("placeName");
            List<Review> list = new ReviewDAO().listByPlace(placeName);

            resp.getWriter().print(new Gson().toJson(list));
            return;
        }

        resp.getWriter().print("{\"ok\":false}");
    }


    // ============================
    // 유틸 메서드
    // ============================

    private Integer parseInt(String s) {
        try {
            return (s == null || s.isBlank()) ? null : Integer.parseInt(s);
        } catch (Exception e) {
            return null;
        }
    }

    private String esc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "");
    }

    // -------------------------------
    // JSON 변환 (키 전부 수정됨)
    // -------------------------------
    private String toJson(List<Map<String, Object>> list) {

        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < list.size(); i++) {

            Map<String, Object> m = list.get(i);

            String author = esc((String) m.get("user"));
            String place = esc((String) m.get("place_name"));
            String content = esc((String) m.get("content"));
            String createdAt = esc((String) m.get("created_at"));  // ★ 수정됨

            int rating = (m.get("rating") instanceof Number)
                    ? ((Number) m.get("rating")).intValue()
                    : 0;

            sb.append("{")
                    .append("\"id\":").append(m.get("id")).append(",")
                    .append("\"placeName\":\"").append(place).append("\",")
                    .append("\"author\":\"").append(author).append("\",")
                    .append("\"rating\":").append(rating).append(",")
                    .append("\"content\":\"").append(content).append("\",")
                    .append("\"createdAt\":\"").append(createdAt).append("\"")
                    .append("}");

            if (i < list.size() - 1) sb.append(",");
        }

        sb.append("]");
        return sb.toString();
    }
}
