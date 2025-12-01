package controller;

import dao.NoticeDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/notice-write")
public class NoticeWriteServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String title = req.getParameter("title");
        String content = req.getParameter("content");

        // 간단한 유효성 검증
        if (title == null || title.trim().isEmpty()
                || content == null || content.trim().isEmpty()) {
            // 제목/내용이 비어 있으면 다시 작성 페이지로 (확실하지만, 에러 처리 방식은 취향)
            resp.sendRedirect(req.getContextPath() + "/notice-write.jsp?error=1");
            return;
        }

        boolean ok;
        try (NoticeDAO dao = new NoticeDAO()) {
            ok = dao.insertNotice(title.trim(), content.trim());
        }

        if (ok) {
            // 성공 시 커뮤니티 메인으로
            resp.sendRedirect(req.getContextPath() + "/community.jsp");
        } else {
            // 실패 시 간단 에러
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "공지 등록에 실패했습니다.");
        }
    }

    // 필요하다면 GET 요청으로 접근 시 작성 페이지로 넘기기 (선택)
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.sendRedirect(req.getContextPath() + "/notice-write.jsp");
    }
}