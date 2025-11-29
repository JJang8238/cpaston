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
        boolean duplicate = false;  // 🚨 중복 신고 체크
        Post updated = null;

        try (PostDAO dao = new PostDAO()) {

            switch (action) {

                case "like":
                case "dislike": {
                    updated = dao.votePost(postId, userId, action);
                    ok = (updated != null);
                    break;
                }

                case "report": {
                    // 신고 수행 → false면 중복 신고임
                    ok = dao.addReport(postId, userId);

                    if (!ok) {
                        duplicate = true;   // 🚨 이미 신고함
                    } else {
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

        // 🚨 중복 신고일 경우
        if (duplicate) {
            out.print("{\"ok\":false, \"message\":\"already\"}");
            return;
        }

        // 실패(like/dislike 실패 시)
        if (!ok || updated == null) {
            out.print("{\"ok\":false}");
            return;
        }

        // 성공 → 좋아요/싫어요/신고수 최신 값 전달
        out.print("{"
                + "\"ok\":true,"
                + "\"likes\":" + updated.getLikes() + ","
                + "\"dislikes\":" + updated.getDislikes() + ","
                + "\"reports\":" + updated.getReports()
                + "}");
    }
}