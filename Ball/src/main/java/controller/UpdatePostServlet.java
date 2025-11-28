package controller;

import dao.PostDAO;
import dto.Post;
import dto.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/updatePost")
public class UpdatePostServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        // 로그인 체크
        User loginUser = (User) req.getSession().getAttribute("loginUser");
        if (loginUser == null) {
            resp.sendRedirect("login.jsp");
            return;
        }
        String loginUsername = loginUser.getUsername();

        // 파라미터 수집
        int id = Integer.parseInt(req.getParameter("id"));
        String title = req.getParameter("title");
        String content = req.getParameter("content");

        // 🔥 board_id 사용
        int boardId = 1;
        try {
            boardId = Integer.parseInt(req.getParameter("board_id"));
        } catch (Exception ignore) {}

        // 어디서 왔는지 체크(community / mypage)
        String from = req.getParameter("from");
        if (from == null) from = "community";

        try (PostDAO dao = new PostDAO()) {

            // 기존 게시글 조회
            Post post = dao.findById(id);
            if (post == null) {
                resp.setContentType("text/html; charset=UTF-8");
                resp.getWriter().println("<script>alert('게시글이 존재하지 않습니다.'); history.back();</script>");
                return;
            }

            // 작성자 체크
            if (!loginUsername.equals(post.getAuthor())) {
                resp.setContentType("text/html; charset=UTF-8");
                resp.getWriter().println("<script>alert('본인이 작성한 글만 수정할 수 있습니다.'); history.back();</script>");
                return;
            }

            // 값 갱신
            post.setTitle(title);
            post.setContent(content);
            post.setBoardId(boardId); // ★ board_id 반영

            // 업데이트 실행
            int result = dao.update(post);

            if (result > 0) {

                // 🔥 수정 성공 후 이동 처리
                if ("mypage".equals(from)) {
                    resp.sendRedirect("mypage.jsp");
                } else {
                    resp.sendRedirect("community.jsp?board_id=" + boardId);
                }

            } else {
                resp.setContentType("text/html; charset=UTF-8");
                resp.getWriter().println("<script>alert('수정에 실패했습니다.'); history.back();</script>");
            }

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
