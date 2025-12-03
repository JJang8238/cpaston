package dao;

import dto.Review;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReviewDAO implements AutoCloseable {

    private Connection conn;

    public ReviewDAO() {
        try {
            conn = DBConnection.getConnection();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private Connection getConn() throws Exception {
        if (conn == null || conn.isClosed()) {
            conn = DBConnection.getConnection();
        }
        return conn;
    }

    // ====================================
    // ⭐ 리뷰 등록
    // ====================================
    public int insert(Review r) {
        final String sql =
                "INSERT INTO place_reviews(place_name, user_id, rating, content) VALUES (?,?,?,?)";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setString(1, r.getPlaceName());
            ps.setInt(2, Integer.parseInt(r.getAuthor()));   // user_id 저장
            ps.setInt(3, r.getRating());
            ps.setString(4, r.getContent());
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ====================================
    // ⭐ 특정 풋살장 리뷰 목록
    // ====================================
    public List<Review> listByPlace(String placeName) {
        final String sql =
                """
                SELECT pr.*, u.username AS author_name
                FROM place_reviews pr
                JOIN user u ON pr.user_id = u.id
                WHERE pr.place_name=?
                ORDER BY pr.id DESC
                """;

        List<Review> list = new ArrayList<>();

        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setString(1, placeName);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(map(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ====================================
    // ⭐ 리뷰가 존재하는 장소 목록
    // ====================================
    public List<String> getReviewedPlaces() {
        final String sql = "SELECT DISTINCT place_name FROM place_reviews ORDER BY place_name ASC";
        List<String> list = new ArrayList<>();

        try (PreparedStatement ps = getConn().prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(rs.getString("place_name"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // ====================================
    // ⭐ 전체 리뷰 목록 (관리자)
    // ====================================
    public List<Review> listAll() {
        final String sql =
                """
                SELECT pr.*, u.username AS author_name
                FROM place_reviews pr
                JOIN user u ON pr.user_id = u.id
                ORDER BY pr.id DESC
                """;

        List<Review> list = new ArrayList<>();

        try (PreparedStatement ps = getConn().prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(map(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ====================================
    // ⭐ 리뷰 삭제
    // ====================================
    public int delete(int id) {
        final String sql = "DELETE FROM place_reviews WHERE id=?";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ====================================
    // ⭐ ResultSet → DTO 매핑
    // ====================================
    private Review map(ResultSet rs) throws SQLException {
        Review r = new Review();

        r.setId(rs.getInt("id"));
        r.setPlaceName(rs.getString("place_name"));
        r.setAuthor(rs.getString("author_name"));   // username 출력
        r.setRating(rs.getInt("rating"));
        r.setContent(rs.getString("content"));
        r.setCreatedAt(rs.getTimestamp("created_at"));

        return r;
    }

    @Override
    public void close() {
        try {
            if (conn != null && !conn.isClosed()) conn.close();
        } catch (SQLException ignore) {}
    }
}