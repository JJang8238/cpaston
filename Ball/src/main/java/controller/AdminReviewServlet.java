package controller;

import dao.ReviewDAO;
import dto.Review;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/review")
public class AdminReviewServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // GET 요청은 거의 사용되지 않지만 혹시 모를 직접 접근 대비
        String place = req.getParameter("place");

        try (ReviewDAO dao = new ReviewDAO()) {

            List<Review> list;

            if (place != null && !place.isEmpty()) {
                list = dao.listByPlace(place);      // 장소별 조회
            } else {
                list = dao.listAll();              // 전체 리뷰 조회
            }

            req.setAttribute("reviewList", list);
            req.getRequestDispatcher("/admin/pages/review_manage.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        if ("delete".equals(action)) {
            int id = Integer.parseInt(req.getParameter("id"));

            try (ReviewDAO dao = new ReviewDAO()) {
                dao.delete(id);    // 리뷰 삭제
            }

            // 삭제 후 다시 리뷰 관리 페이지로 이동
            resp.sendRedirect(req.getContextPath() + "/admin/admin_menu.jsp?page=review");
        }
    }
}
