package dao;

import util.DBConnection;

import java.sql.*;
import java.util.*;

public class PlaceReviewDAO implements AutoCloseable {

    @Override
    public void close() {
        // 아무것도 안 함 (연결은 try-with-resources에서 처리됨)
    }

    // ======================================================
    // 0) 장소별 리뷰 목록 조회 (기본: 최신순) - 기존 코드와의 호환용
    // ======================================================
    public List<Map<String, Object>> listByPlace(String placeName) {
        // 기본은 최신순
        return listByPlace(placeName, "newest");
    }

    // ======================================================
    // 1) 장소별 리뷰 목록 조회 (+ 정렬 옵션)
    //    sort: newest, oldest, high, low
    // ======================================================
    public List<Map<String, Object>> listByPlace(String placeName, String sort) {
        List<Map<String, Object>> list = new ArrayList<>();

        // 정렬 기준 결정
        String orderBy;
        if ("oldest".equals(sort)) {
            orderBy = " ORDER BY r.created_at ASC";
        } else if ("high".equals(sort)) {
            orderBy = " ORDER BY r.rating DESC, r.created_at DESC";
        } else if ("low".equals(sort)) {
            orderBy = " ORDER BY r.rating ASC, r.created_at DESC";
        } else {
            // 기본: 최신순
            orderBy = " ORDER BY r.created_at DESC";
        }

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
        """ + orderBy;

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
    // 2) 사용자별 리뷰 목록 조회
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
    // 5-1) 사용자용 삭제 (reviewId + userId)
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

    // ======================================================
    // 5-2) 관리자용 삭제 (reviewId만)
    // ======================================================
    public boolean adminDelete(int reviewId) {

        String sql = """
            DELETE FROM place_reviews
            WHERE id = ?
        """;

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, reviewId);
            return ps.executeUpdate() == 1;

        } catch (Exception e) { e.printStackTrace(); }

        return false;
    }
}