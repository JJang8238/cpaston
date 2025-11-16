package dao;

import util.DBConnection;

import java.sql.*;
import java.util.*;

public class PlaceReviewDAO {

    // ======================================================
    // 1) 장소별 리뷰 목록 조회
    // ======================================================
    public List<Map<String, Object>> listByPlace(String placeName) {
        List<Map<String, Object>> list = new ArrayList<>();

        String sql = """
          SELECT r.id,
                 r.user_id,
                 u.username,
                 r.place_name,
                 r.rating,
                 r.content,
                 DATE_FORMAT(r.created_at,'%Y-%m-%d %H:%i') created_at
          FROM place_reviews r
          JOIN `user` u ON u.id = r.user_id
          WHERE r.place_name = ?
          ORDER BY r.id DESC
        """;

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, placeName);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("id", rs.getInt("id"));
                    m.put("userId", rs.getInt("user_id"));
                    m.put("user", rs.getString("username"));
                    m.put("place_name", rs.getString("place_name"));
                    m.put("rating", rs.getInt("rating"));
                    m.put("content", rs.getString("content"));
                    m.put("created_at", rs.getString("created_at"));
                    list.add(m);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }

        return list;
    }

    // ======================================================
    // ⭐⭐ 2) 사용자별 리뷰 목록 조회 (마이페이지에서 사용)
    // ======================================================
    public List<Map<String, Object>> listByUser(int userId) {
        List<Map<String, Object>> list = new ArrayList<>();

        String sql = """
          SELECT r.id,
                 r.place_name,
                 r.rating,
                 r.content,
                 DATE_FORMAT(r.created_at,'%Y-%m-%d %H:%i') created_at
          FROM place_reviews r
          WHERE r.user_id = ?
          ORDER BY r.id DESC
        """;

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("id", rs.getInt("id"));
                    m.put("place_name", rs.getString("place_name"));
                    m.put("rating", rs.getInt("rating"));
                    m.put("content", rs.getString("content"));
                    m.put("created_at", rs.getString("created_at"));
                    list.add(m);
                }
            }

        } catch (Exception e) { e.printStackTrace(); }

        return list;
    }


    // ======================================================
    // 3) 리뷰 추가
    // ======================================================
    public boolean add(int userId, String placeName, Integer rating, String content) {

        String sql = "INSERT INTO place_reviews (user_id, place_name, rating, content) VALUES (?,?,?,?)";

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setString(2, placeName);

            if (rating == null) ps.setNull(3, Types.TINYINT);
            else ps.setInt(3, rating);

            ps.setString(4, content);

            return ps.executeUpdate() == 1;

        } catch (Exception e) { e.printStackTrace(); }

        return false;
    }


    // ======================================================
    // 4) 리뷰 수정
    // ======================================================
    public boolean update(int reviewId, int userId, int rating, String content) {

        String sql = """
            UPDATE place_reviews
            SET rating = ?, content = ?
            WHERE id = ? AND user_id = ?
        """;

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, rating);
            ps.setString(2, content);
            ps.setInt(3, reviewId);
            ps.setInt(4, userId);

            return ps.executeUpdate() == 1;

        } catch (Exception e) { e.printStackTrace(); }

        return false;
    }


    // ======================================================
    // 5) 리뷰 삭제
    // ======================================================
    public boolean delete(int reviewId, int userId) {

        String sql = """
            DELETE FROM place_reviews
            WHERE id = ? AND user_id = ?
        """;

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, reviewId);
            ps.setInt(2, userId);

            return ps.executeUpdate() == 1;

        } catch (Exception e) { e.printStackTrace(); }

        return false;
    }
}
