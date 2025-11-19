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

        // 어디에서 삭제 요청이 왔는지 (community / mypage)
        String from = req.getParameter("from");
        if (from == null) from = "community";  // 기본값

        // 로그인 체크
        User loginUser = (User) req.getSession().getAttribute("loginUser");
        if (loginUser == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        String loginUsername = loginUser.getUsername();
        int postId = Integer.parseInt(req.getParameter("postId"));

        try (PostDAO dao = new PostDAO()) {

            // 게시글 조회
            Post post = dao.findById(postId);

            if (post == null) {
                resp.setContentType("text/html; charset=UTF-8");
                resp.getWriter().println("<script>alert('게시글을 찾을 수 없습니다.'); history.back();</script>");
                return;
            }

            // 작성자 검증
            if (!post.getAuthor().equals(loginUsername)) {
                resp.setContentType("text/html; charset=UTF-8");
                resp.getWriter().println("<script>alert('본인이 작성한 글만 삭제할 수 있습니다.'); history.back();</script>");
                return;
            }

            // 삭제 실행
            int result = dao.deletePost(postId);

            if (result > 0) {

                // 🔥 삭제 성공 시 돌아갈 위치 구분
                if ("mypage".equals(from)) {
                    resp.sendRedirect("mypage.jsp");
                } else {
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
