package controller;

import dao.NoticeDAO;
import dto.Notice;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/notice")
public class NoticeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html; charset=UTF-8");

        int id = Integer.parseInt(req.getParameter("id"));

        try (NoticeDAO dao = new NoticeDAO()) {
            Notice n = dao.findById(id);

            PrintWriter out = resp.getWriter();

            if (n == null) {
                out.println("<p>공지사항을 찾을 수 없습니다.</p>");
                return;
            }

            out.println("<h5 class='fw-bold'>" + n.getTitle() + "</h5>");
            out.println("<hr>");
            out.println("<p>" + n.getContent().replace("\n", "<br>") + "</p>");
            out.println("<div class='text-end text-muted small mt-3'>작성일: " + n.getCreatedAt() + "</div>");
        }
    }
}
