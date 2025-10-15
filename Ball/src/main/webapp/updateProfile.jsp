<%@ page contentType="text/html; charset=UTF-8" session="true" %>
<%@ page import="java.io.*, jakarta.servlet.http.*, jakarta.servlet.*, dto.User, dao.UserDAO" %>

<%
    request.setCharacterEncoding("UTF-8");
    User user = (User) session.getAttribute("user");

    if (user == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    // multipart/form-data 확인
    if (request.getContentType() == null || !request.getContentType().toLowerCase().startsWith("multipart/")) {
        out.println("<h3>❌ 잘못된 요청 형식입니다. (multipart/form-data 아님)</h3>");
        return;
    }

    // 업로드 경로 준비
    String uploadPath = application.getRealPath("/uploads");
    File uploadDir = new File(uploadPath);
    if (!uploadDir.exists()) uploadDir.mkdirs();

    // 폼 데이터 변수
    String name = user.getName();
    String email = user.getEmail();
    String newPassword = null;
    String profileImagePath = user.getProfileImage();

    try {
        // Servlet 3.0 표준 업로드 방식 사용
        for (Part part : request.getParts()) {
            String fieldName = part.getName();

            if (part.getContentType() == null) {
                // 일반 입력값 처리
                String value = request.getParameter(fieldName);
                if ("name".equals(fieldName) && value != null && !value.isEmpty()) name = value;
                if ("email".equals(fieldName) && value != null && !value.isEmpty()) email = value;
                if ("newPassword".equals(fieldName) && value != null && !value.isEmpty()) newPassword = value;
            } 
            else if ("profileImage".equals(fieldName) && part.getSize() > 0) {
                // 이미지 업로드 처리
                String fileName = part.getSubmittedFileName();
                if (fileName != null && !fileName.isEmpty()) {
                    String saveFileName = System.currentTimeMillis() + "_" + fileName;
                    part.write(uploadPath + File.separator + saveFileName);
                    profileImagePath = "uploads/" + saveFileName;
                }
            }
        }

        // 변경된 정보 User 객체에 반영
        user.setName(name);
        user.setEmail(email);
        user.setProfileImage(profileImagePath);

        // DB 업데이트 수행
        UserDAO dao = new UserDAO();
        boolean updated = dao.updateUserProfile(user, newPassword);

        if (updated) {
            session.setAttribute("user", user);
            response.sendRedirect("mypage.jsp");
        } else {
            out.println("<h3>⚠️ 프로필 업데이트 실패</h3>");
            out.println("<a href='editProfile.jsp'>돌아가기</a>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<h3>❌ 오류 발생: " + e.getMessage() + "</h3>");
    }
%>
