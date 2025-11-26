package controller;

import dao.PostDAO;
import dto.Post;
import dto.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/post-like")
public class PostLikeServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");

        HttpSession session = req.getSession(false);
        User loginUser = (session != null) ? (User) session.getAttribute("loginUser") : null;

        // 로그인 체크
        if (loginUser == null) {
            resp.getWriter().print("{\"ok\":false,\"message\":\"login\"}");
            return;
        }

        // ⭐ 여기서는 user의 PK(id)를 사용 (post_vote_log / post_report_log 의 user_id 가 INT 라는 가정)
        int userId = loginUser.getId();

        String action = req.getParameter("action");  // like / dislike / report
        int postId;

        try {
            postId = Integer.parseInt(req.getParameter("id"));
        } catch (Exception e) {
            resp.getWriter().print("{\"ok\":false,\"message\":\"bad id\"}");
            return;
        }

        boolean ok = false;
        Post updated = null;

        try (PostDAO dao = new PostDAO()) {

            switch (action) {

                case "like":
                case "dislike": {
                    // 좋아요/싫어요 토글
                    updated = dao.votePost(postId, userId, action);
                    ok = (updated != null);
                    break;
                }

                case "report": {
                    // 신고 (한 번만 가능)
                    ok = dao.addReport(postId, userId);
                    if (ok) {
                        updated = dao.findById(postId);
                    }
                    break;
                }

                default:
                    ok = false;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        PrintWriter out = resp.getWriter();

        if (!ok || updated == null) {
            // 신고 중복 등으로 실패했을 때
            out.print("{\"ok\":false}");
            return;
        }

        // 👍 / 👎 / 🚨 모두 공통으로 최신 값 내려줌
        out.print("{"
                + "\"ok\":true,"
                + "\"likes\":" + updated.getLikes() + ","
                + "\"dislikes\":" + updated.getDislikes() + ","
                + "\"reports\":" + updated.getReports()
                + "}");
    }
}