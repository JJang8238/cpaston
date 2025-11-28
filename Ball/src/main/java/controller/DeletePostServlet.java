package controller;

import dao.PostDAO;
import dto.Post;
import dto.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/deletePost")
public class DeletePostServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        // 어디서 요청이 왔는지 (community / mypage / admin)
        String from = req.getParameter("from");
        if (from == null) from = "community";

        // 로그인 체크
        User loginUser = (User) req.getSession().getAttribute("loginUser");
        if (loginUser == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        String loginUsername = loginUser.getUsername();
        String loginRole = loginUser.getRole();   // 🔥 admin 여부 체크

        // -----------------------------
        // 🔥 postId 또는 id 모두 허용
        // -----------------------------
        int postId = 0;

        try {
            if (req.getParameter("postId") != null) {
                postId = Integer.parseInt(req.getParameter("postId"));
            } else if (req.getParameter("id") != null) {
                postId = Integer.parseInt(req.getParameter("id"));
            } else {
                throw new Exception("잘못된 파라미터");
            }
        } catch (Exception e) {
            resp.setContentType("text/html; charset=UTF-8");
            resp.getWriter().println("<script>alert('잘못된 게시글 번호입니다.'); history.back();</script>");
            return;
        }

        try (PostDAO dao = new PostDAO()) {

            // 게시글 조회
            Post post = dao.findById(postId);

            if (post == null) {
                resp.setContentType("text/html; charset=UTF-8");
                resp.getWriter().println("<script>alert('게시글을 찾을 수 없습니다.'); history.back();</script>");
                return;
            }

            // ----------------------------------------
            // 🔥 일반 사용자는 본인 글만 삭제 가능
            // 🔥 관리자(admin)은 모든 글 삭제 가능
            // ----------------------------------------
            if (!"admin".equals(loginRole) && !post.getAuthor().equals(loginUsername)) {
                resp.setContentType("text/html; charset=UTF-8");
                resp.getWriter().println("<script>alert('본인이 작성한 글만 삭제할 수 있습니다.'); history.back();</script>");
                return;
            }

            // 삭제 실행
            int result = dao.deletePost(postId);

            if (result > 0) {

                // 🔥 삭제 성공 후 이동 경로 구분
                switch (from) {
                    case "mypage":
                        resp.sendRedirect("mypage.jsp");
                        break;

                    case "admin":
                        resp.sendRedirect("admin/admin_menu.jsp?page=report");
                        break;

                    default:
                        resp.sendRedirect("community.jsp");
                }

            } else {
                resp.setContentType("text/html; charset=UTF-8");
                resp.getWriter().println("<script>alert('삭제 실패'); history.back();</script>");
            }

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
