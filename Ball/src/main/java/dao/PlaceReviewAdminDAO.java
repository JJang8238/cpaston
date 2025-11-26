package dao;

import util.DBConnection;

import java.sql.*;
import java.util.*;

public class PlaceReviewAdminDAO implements AutoCloseable {

	@Override
	public void close() {
	    // 아무 것도 안 해도 됨
	}

    // ============================================
    // 1. 리뷰가 존재하는 장소 목록 조회
    // ============================================
    public List<String> getReviewedPlaces() {
        List<String> list = new ArrayList<>();

        String sql = """
            SELECT DISTINCT place_name
            FROM place_reviews
            ORDER BY place_name ASC
        """;

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(rs.getString("place_name"));
            }

        } catch (Exception e) { e.printStackTrace(); }

        return list;
    }

    // ============================================
    // 2. 특정 장소 리뷰 목록
    // ============================================
    public List<Map<String, Object>> listByPlace(String placeName) {
        List<Map<String, Object>> list = new ArrayList<>();

        String sql = """
            SELECT r.id,
                   r.user_id,
                   u.username,
                   r.place_name,
                   r.rating,
                   r.content,
                   DATE_FORMAT(r.created_at, '%Y-%m-%d %H:%i') AS created_at
            FROM place_reviews r
            JOIN user u ON u.id = r.user_id
            WHERE r.place_name = ?
            ORDER BY r.id DESC
        """;

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, placeName);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getInt("id"));
                    row.put("userId", rs.getInt("user_id"));
                    row.put("user", rs.getString("username"));
                    row.put("place_name", rs.getString("place_name"));
                    row.put("rating", rs.getInt("rating"));
                    row.put("content", rs.getString("content"));
                    row.put("created_at", rs.getString("created_at"));
                    list.add(row);
                }
            }

        } catch (Exception e) { e.printStackTrace(); }

        return list;
    }

    // ============================================
    // 3. 전체 리뷰 목록 조회 (관리자용)
    // ============================================
    public List<Map<String, Object>> listAll() {
        List<Map<String, Object>> list = new ArrayList<>();

        String sql = """
            SELECT r.id,
                   r.user_id,
                   u.username,
                   r.place_name,
                   r.rating,
                   r.content,
                   DATE_FORMAT(r.created_at, '%Y-%m-%d %H:%i') AS created_at
            FROM place_reviews r
            JOIN user u ON u.id = r.user_id
            ORDER BY r.id DESC
        """;

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getInt("id"));
                row.put("userId", rs.getInt("user_id"));
                row.put("user", rs.getString("username"));
                row.put("place_name", rs.getString("place_name"));
                row.put("rating", rs.getInt("rating"));
                row.put("content", rs.getString("content"));
                row.put("created_at", rs.getString("created_at"));
                list.add(row);
            }

        } catch (Exception e) { e.printStackTrace(); }

        return list;
    }

    // ============================================
    // 4. 리뷰 삭제 (관리자 권한)
    // ============================================
    public boolean delete(int reviewId) {

        String sql = "DELETE FROM place_reviews WHERE id = ?";

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, reviewId);
            return ps.executeUpdate() == 1;

        } catch (Exception e) { e.printStackTrace(); }

        return false;
    }
}