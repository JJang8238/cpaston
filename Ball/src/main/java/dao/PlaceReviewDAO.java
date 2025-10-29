package dao;

import util.DBConnection;
import java.sql.*;
import java.util.*;

public class PlaceReviewDAO {
    public List<Map<String,Object>> listByPlace(String placeName){
        List<Map<String,Object>> list = new ArrayList<>();
        String sql = """
          SELECT r.id, u.username, r.rating, r.content,
                 DATE_FORMAT(r.created_at,'%Y-%m-%d %H:%i') created_at
          FROM place_reviews r JOIN `user` u ON u.id=r.user_id
          WHERE r.place_name=? ORDER BY r.id DESC
        """;
        try(Connection c=DBConnection.getConnection(); PreparedStatement ps=c.prepareStatement(sql)){
            ps.setString(1, placeName);
            try(ResultSet rs=ps.executeQuery()){
                while(rs.next()){
                    Map<String,Object> m=new HashMap<>();
                    m.put("id", rs.getInt("id"));
                    m.put("user", rs.getString("username"));
                    m.put("rating", (Integer)rs.getObject("rating"));
                    m.put("content", rs.getString("content"));
                    m.put("createdAt", rs.getString("created_at"));
                    list.add(m);
                }
            }
        }catch(Exception e){ e.printStackTrace(); }
        return list;
    }
}
