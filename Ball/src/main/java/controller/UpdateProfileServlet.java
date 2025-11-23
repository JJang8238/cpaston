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
        fileSizeThreshold = 1024 * 1024,        // 1MB 메모리 임계값
        maxFileSize = 1024 * 1024 * 10,        // 파일 10MB
        maxRequestSize = 1024 * 1024 * 50      // 요청 전체 50MB
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
        String profileImage = loginUser.getProfileImage(); // 기본 = 기존 이미지

        if (filePart != null && filePart.getSize() > 0) {
            String originalName = filePart.getSubmittedFileName();

            String ext = "";
            int dot = originalName.lastIndexOf(".");
            if (dot != -1) ext = originalName.substring(dot);

            // 파일명 규칙 : user_회원ID_시간.ext
            String saveName = "user_" + loginUser.getId() + "_" + System.currentTimeMillis() + ext;

            String uploadDirPath = request.getServletContext().getRealPath("/uploads");
            File uploadDir = new File(uploadDirPath);
            if (!uploadDir.exists()) uploadDir.mkdirs();

            filePart.write(uploadDirPath + File.separator + saveName);

            // DB에 저장할 경로
            profileImage = "uploads/" + saveName;
        }

        // ----------------------------
        // 3) DTO 값 반영
        // ----------------------------
        loginUser.setName(name);
        loginUser.setEmail(email);
        loginUser.setProfileImage(profileImage);

        // ----------------------------
        // 4) DB 업데이트
        // ----------------------------
        UserDAO dao = new UserDAO();

        try {
            boolean success = dao.updateUserProfile(loginUser, newPassword);

            if (success) {
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
