package controller;

import dto.User;
import dao.UserDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.File;
import java.io.IOException;

@WebServlet("/updateProfile")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 1024 * 1024 * 10,
        maxRequestSize = 1024 * 1024 * 50
)
public class UpdateProfileServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User loginUser = (session != null) ? (User) session.getAttribute("loginUser") : null;

        if (loginUser == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        // ----------------------------
        // 1) 폼 데이터 수집
        // ----------------------------
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String newPassword = request.getParameter("newPassword");

        // ----------------------------
        // 2) 프로필 이미지 처리
        // ----------------------------
        Part filePart = request.getPart("profileImage");
        String newProfileImage = loginUser.getProfileImage(); // 기존 이미지 유지

        if (filePart != null && filePart.getSize() > 0) {
            String originalName = filePart.getSubmittedFileName();

            String ext = "";
            int dot = originalName.lastIndexOf(".");
            if (dot != -1) ext = originalName.substring(dot);

            newProfileImage = "user_" + loginUser.getId() + "_" + System.currentTimeMillis() + ext;

            String uploadPath = request.getServletContext().getRealPath("/uploads");
            File dir = new File(uploadPath);
            if (!dir.exists()) dir.mkdirs();

            filePart.write(uploadPath + File.separator + newProfileImage);
        }

        // DTO에 반영
        loginUser.setName(name);
        loginUser.setEmail(email);
        loginUser.setProfileImage(newProfileImage);

        // ----------------------------
        // 3) DAO 호출
        // ----------------------------
        UserDAO dao = new UserDAO();

        try {
            boolean ok = dao.updateUserProfile(loginUser, newPassword);

            if (ok) {
                session.setAttribute("loginUser", loginUser);
                response.sendRedirect("mypage.jsp?result=success");
            } else {
                response.sendRedirect("editProfile.jsp?error=updateFail");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("editProfile.jsp?error=exception");
        } finally {
            dao.close();
        }
    }
}
