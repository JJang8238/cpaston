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
        String category = req.getParameter("category");

        // 🔥 어디서 왔는지 확인 (community / mypage)
        String from = req.getParameter("from");
        if (from == null) from = "community"; // 기본값

        try (PostDAO dao = new PostDAO()) {

            // 기존 게시글 가져오기
            Post post = dao.findById(id);
            if (post == null) {
                resp.setContentType("text/html; charset=UTF-8");
                resp.getWriter().println("<script>alert('게시글이 존재하지 않습니다.'); history.back();</script>");
                return;
            }

            // 작성자 검증
            if (!loginUsername.equals(post.getAuthor())) {
                resp.setContentType("text/html; charset=UTF-8");
                resp.getWriter().println("<script>alert('본인이 작성한 글만 수정할 수 있습니다.'); history.back();</script>");
                return;
            }

            // 새 값으로 객체 갱신
            post.setTitle(title);
            post.setContent(content);
            post.setCategory(category);

            // 업데이트 실행
            int result = dao.update(post);

            if (result > 0) {

                // 🔥 수정 성공 후 이동 처리
                if ("mypage".equals(from)) {
                    // 마이페이지에서 수정한 경우
                    resp.sendRedirect("mypage.jsp");
                } else {
                    // 기본은 커뮤니티
                    resp.sendRedirect("community.jsp?category=" 
                                      + java.net.URLEncoder.encode(category, "UTF-8"));
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
