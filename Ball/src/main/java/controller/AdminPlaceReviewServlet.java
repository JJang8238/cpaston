package controller;

import dao.PlaceReviewAdminDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/place-review")
public class AdminPlaceReviewServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String place = req.getParameter("place");

        try (PlaceReviewAdminDAO dao = new PlaceReviewAdminDAO()) {

            List<String> places = dao.getReviewedPlaces();
            List<Map<String,Object>> list;

            if (place != null && !place.isEmpty()) {
                list = dao.listByPlace(place);
            } else {
                list = dao.listAll();
            }

            // 데이터만 넘기기
            req.setAttribute("places", places);
            req.setAttribute("reviewList", list);
            req.setAttribute("selectedPlace", place);

            // ⭐ 관리자 레이아웃을 열고 내부에서 review_manage.jsp 포함
            req.getRequestDispatcher("/admin/admin_menu.jsp?page=review")
               .forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        if ("delete".equals(req.getParameter("action"))) {
            int id = Integer.parseInt(req.getParameter("id"));
            try (PlaceReviewAdminDAO dao = new PlaceReviewAdminDAO()) {
                dao.delete(id);
            }
        }

        // 삭제 후에도 동일한 방식으로 이동
        resp.sendRedirect(req.getContextPath() + "/admin/place-review");
    }
}
