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

        // ================================
        // 장소별 리뷰 목록
        // ================================
        if ("listByPlace".equals(action)) {

            String place = req.getParameter("place");
            List<Map<String, Object>> list = new PlaceReviewDAO().listByPlace(place);

            // 평균 평점 계산
            double sum = 0;
            int count = 0;
            for (var r : list) {
                Object ratingObj = r.get("rating");
                if (ratingObj != null) {
                    count++;
                    sum += ((Number) ratingObj).doubleValue();
                }
            }

            double avg = (count == 0 ? 0 : sum / count);

            // JSON 반환
            StringBuilder sb = new StringBuilder();
            sb.append("{");
            sb.append("\"avgRating\":").append(String.format("%.1f", avg)).append(",");
            sb.append("\"count\":").append(list.size()).append(",");
            sb.append("\"reviews\":").append(toJson(list));
            sb.append("}");

            resp.getWriter().print(sb.toString());
            return;
        }

        // ================================
        // 경기별 리뷰 목록
        // ================================
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
        HttpSession s = req.getSession();

        User loginUser = (User) s.getAttribute("loginUser");
        if (loginUser == null) {
            resp.getWriter().print("{\"ok\":false, \"message\":\"login\"}");
            return;
        }

        int userId = loginUser.getId();
        boolean ok = false;

        /* =====================================================
            🔥 장소 리뷰 추가 (addByPlace)
        ===================================================== */
        if ("add".equals(action) || "addByPlace".equals(action)) {

            String placeName = req.getParameter("place");
            Integer rating = parseInt(req.getParameter("rating"));
            String content = req.getParameter("content");

            ok = new PlaceReviewDAO().add(userId, placeName, rating, content);

            resp.getWriter().print("{\"ok\":" + ok + "}");
            return;
        }

        /* =====================================================
            🔥 경기 리뷰 추가 (addByMatch)
        ===================================================== */
        else if ("addByMatch".equals(action)) {

            int matchId = Integer.parseInt(req.getParameter("matchId"));
            Integer rating = parseInt(req.getParameter("rating"));
            String content = req.getParameter("content");

            ok = new MatchReviewDAO().add(userId, matchId, rating, content);

            resp.getWriter().print("{\"ok\":" + ok + "}");
            return;
        }

        /* =====================================================
            🔥 장소 리뷰 수정 (update / updateByPlace)
            - 작성자(userId) 검증은 DAO에서 id + user_id 조건으로 처리
        ===================================================== */
        else if ("update".equals(action) || "updateByPlace".equals(action)) {

            int reviewId = Integer.parseInt(req.getParameter("id"));
            Integer rating = parseInt(req.getParameter("rating"));
            String content = req.getParameter("content");

            ok = new PlaceReviewDAO().update(reviewId, userId,
                                             rating != null ? rating : 0,
                                             content);

            resp.getWriter().print("{\"ok\":" + ok + "}");
            return;
        }

        /* =====================================================
            🔥 장소 리뷰 삭제 (delete / deleteByPlace)
        ===================================================== */
        else if ("delete".equals(action) || "deleteByPlace".equals(action)) {

            int reviewId = Integer.parseInt(req.getParameter("id"));

            ok = new PlaceReviewDAO().delete(reviewId, userId);

            resp.getWriter().print("{\"ok\":" + ok + "}");
            return;
        }

        /* =====================================================
            🔥 (기존) placeName 으로 ReviewDTO 리스트 반환
            - 예전 AJAX 코드 호환용
        ===================================================== */
        else if (req.getParameter("placeName") != null) {

            String placeName = req.getParameter("placeName");

            List<Review> lstPlace = new ReviewDAO().listByPlace(placeName);

            Gson gson = new Gson();
            String json = gson.toJson(lstPlace);

            resp.getWriter().print(json);
            return;
        }

        resp.getWriter().print("{\"ok\":false}");
    }

    /* ======================= 유틸 ======================= */

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

    /* =====================================================
        리스트<Map<String,Object>> → JSON 배열 변환
       ⭐ null-safe 처리되어 JSON 깨지는 문제 해결 ⭐
    ===================================================== */
    private String toJson(List<Map<String, Object>> list) {

        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < list.size(); i++) {

            Map<String, Object> m = list.get(i);

            Integer rating = (m.get("rating") instanceof Number) ?
                    ((Number) m.get("rating")).intValue() : 0;

            String author = esc((String) m.get("user"));
            String content = esc((String) m.get("content"));
            String createdAt = esc((String) m.get("createdAt"));

            sb.append("{")
              .append("\"id\":").append(m.get("id")).append(",")
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
