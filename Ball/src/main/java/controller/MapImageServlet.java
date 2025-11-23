package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.net.URLDecoder;

@WebServlet("/mapImage")
public class MapImageServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        // placeName 받아오기
        String name = req.getParameter("name");
        if (name == null) return;

        // UTF-8 디코딩
        name = URLDecoder.decode(name, "UTF-8");

        // 공백 제거
        String safeName = name.replaceAll("\\s+", "");

        // 이미지 폴더 위치
        String folder = getServletContext().getRealPath("/assets/place/");

        // jpg, png 자동 탐색
        File jpg = new File(folder, safeName + ".jpg");
        File png = new File(folder, safeName + ".png");

        File imgFile = jpg.exists() ? jpg : (png.exists() ? png : null);

        if (imgFile == null) {
            // 기본 이미지 제공
            imgFile = new File(getServletContext().getRealPath("/assets/img/field-default.png"));
        }

        resp.setContentType("image/jpeg");

        // 파일 내려보내기
        try (FileInputStream fis = new FileInputStream(imgFile);
             OutputStream out = resp.getOutputStream()) {

            byte[] buf = new byte[1024];
            int len;
            while ((len = fis.read(buf)) != -1) {
                out.write(buf, 0, len);
            }
        }
    }
}
