package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/updateRole")
public class AdminUpdateRoleServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String sid = req.getParameter("id");
        String role = req.getParameter("role");

        if (sid != null && role != null) {
            int id = Integer.parseInt(sid);

            UserDAO dao = new UserDAO();
            boolean result = dao.updateUserRole(id, role);

            if (result) {
                resp.sendRedirect(req.getContextPath() + "/admin/admin_menu.jsp?page=user");
            } else {
                resp.getWriter().println("<script>alert('권한 변경 실패');history.back();</script>");
            }
        }
    }
}
