package controller;

import dao.MatchReviewDAO;
import dao.PlaceReviewDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/review")
public class ReviewServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, jakarta.servlet.http.HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        String action = req.getParameter("action");
        if ("listByPlace".equals(action)) {
            String place = req.getParameter("place");
            List<Map<String,Object>> list = new PlaceReviewDAO().listByPlace(place);
            resp.getWriter().print(toJson(list));
        } else if ("listByMatch".equals(action)) {
            int matchId = Integer.parseInt(req.getParameter("matchId"));
            List<Map<String,Object>> list = new MatchReviewDAO().listByMatch(matchId);
            resp.getWriter().print(toJson(list));
        } else {
            resp.getWriter().print("[]");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, jakarta.servlet.http.HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");

        String action = req.getParameter("action");
        HttpSession s = req.getSession();
        // 로그인 세션에서 username → userId를 구하는 로직이 있으면 사용하세요.
        // 여기선 세션에 userId가 있다고 가정
        Integer userId = (Integer) s.getAttribute("userId");
        if (userId == null) { resp.getWriter().print("{\"ok\":false,\"msg\":\"login\"}"); return; }

        boolean ok = false;
        if ("addByMatch".equals(action)) {
            int matchId = Integer.parseInt(req.getParameter("matchId"));
            Integer rating = parseInt(req.getParameter("rating"));
            String content = req.getParameter("content");
            ok = new MatchReviewDAO().add(userId, matchId, rating, content);
        }
        resp.getWriter().print("{\"ok\":"+ok+"}");
    }

    private Integer parseInt(String s){ try{ return (s==null||s.isBlank())?null:Integer.parseInt(s);}catch(Exception e){return null;} }
    private String esc(String s){ return s==null? "": s.replace("\\","\\\\").replace("\"","\\\""); }
    private String toJson(List<Map<String,Object>> list){
        StringBuilder sb=new StringBuilder("[");
        for(int i=0;i<list.size();i++){
            var m=list.get(i);
            sb.append("{")
              .append("\"id\":").append(m.get("id")).append(",")
              .append("\"user\":\"").append(esc((String)m.get("user"))).append("\",")
              .append("\"rating\":").append(m.get("rating")==null?"null":m.get("rating")).append(",")
              .append("\"content\":\"").append(esc((String)m.get("content"))).append("\",")
              .append("\"createdAt\":\"").append(esc((String)m.get("createdAt"))).append("\"")
              .append("}");
            if(i<list.size()-1) sb.append(",");
        }
        sb.append("]");
        return sb.toString();
    }
}
