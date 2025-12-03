package dao;

import util.DBConnection;
import java.sql.*;
import java.util.*;

public class MatchReviewDAO {

    // ======================================================
    // 1) 경기 리뷰 추가
    // ======================================================
    public boolean add(int userId, int matchReservationId, Integer rating, String content) {
        String sql = "INSERT INTO match_reviews(user_id, match_reservation_id, rating, content) VALUES (?,?,?,?)";

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, matchReservationId);
            if (rating == null) ps.setNull(3, Types.TINYINT);
            else ps.setInt(3, rating);
            ps.setString(4, content);

            return ps.executeUpdate() == 1;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }


    // ======================================================
    // 2) 특정 경기(matchId) 리뷰 목록 조회
    // ======================================================
    public List<Map<String,Object>> listByMatch(int matchReservationId) {

        List<Map<String,Object>> list = new ArrayList<>();

        String sql = """
          SELECT r.id, r.user_id, u.username, r.rating, r.content,
                 DATE_FORMAT(r.created_at,'%Y-%m-%d %H:%i') created_at
          FROM match_reviews r 
          JOIN `user` u ON u.id = r.user_id
          WHERE r.match_reservation_id = ?
          ORDER BY r.id DESC
        """;

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, matchReservationId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> m = new HashMap<>();
                    m.put("id", rs.getInt("id"));
                    m.put("userId", rs.getInt("user_id"));   // ⭐ 수정/삭제 권한 체크용
                    m.put("user", rs.getString("username"));
                    m.put("rating", (Integer) rs.getObject("rating"));
                    m.put("content", rs.getString("content"));
                    m.put("createdAt", rs.getString("created_at"));
                    list.add(m);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }


    // ======================================================
    // 3) ⭐ 사용자(userId) 기준, 내가 작성한 경기 리뷰 조회 (mypage.jsp 용)
    // ======================================================
    public List<Map<String,Object>> listByUser(int userId) {

        List<Map<String,Object>> list = new ArrayList<>();

        String sql = """
          SELECT r.id,
                 r.match_reservation_id,
                 r.rating,
                 r.content,
                 DATE_FORMAT(r.created_at,'%Y-%m-%d %H:%i') created_at
          FROM match_reviews r
          WHERE r.user_id = ?
          ORDER BY r.id DESC
        """;

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {

                    Map<String,Object> m = new HashMap<>();
                    m.put("id", rs.getInt("id"));
                    m.put("match_id", rs.getInt("match_reservation_id"));
                    m.put("rating", (Integer) rs.getObject("rating"));
                    m.put("content", rs.getString("content"));
                    m.put("created_at", rs.getString("created_at"));

                    list.add(m);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
}