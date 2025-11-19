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

    // 리뷰 등록
    public int insert(Review r) {
        final String sql =
                "INSERT INTO review(place_name, author, rating, content) VALUES (?,?,?,?)";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setString(1, r.getPlaceName());
            ps.setString(2, r.getAuthor());
            ps.setInt(3, r.getRating());
            ps.setString(4, r.getContent());
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // 특정 풋살장 리뷰 목록
    public List<Review> listByPlace(String placeName) {
        final String sql =
                "SELECT * FROM review WHERE place_name=? ORDER BY id DESC";
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

    private Review map(ResultSet rs) throws SQLException {
        Review r = new Review();
        r.setId(rs.getInt("id"));
        r.setPlaceName(rs.getString("place_name"));
        r.setAuthor(rs.getString("author"));
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
