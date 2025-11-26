package controller;

import dao.UserDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/admin/deleteUser")
public class AdminDeleteUserServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String sid = req.getParameter("id");

        if (sid != null) {
            int id = Integer.parseInt(sid);

            UserDAO dao = new UserDAO();
            boolean result = dao.deleteUser(id);

            if (result) {
                resp.sendRedirect(req.getContextPath() + "/admin/admin_menu.jsp?page=user");
            } else {
                resp.getWriter().println("<script>alert('삭제 실패');history.back();</script>");
            }
        }
    }
}