package dao;

import dto.Post;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PostDAO implements AutoCloseable {
    private Connection conn;

    public PostDAO() {
        try { conn = DBConnection.getConnection(); }
        catch (Exception e) { e.printStackTrace(); }
    }

    private Connection getConn() throws Exception {
        if (conn == null || conn.isClosed()) conn = DBConnection.getConnection();
        return conn;
    }

    public int insert(Post p) {
        final String sql = "INSERT INTO post(title, content, category, author) VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = getConn().prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, p.getTitle());
            ps.setString(2, p.getContent());
            ps.setString(3, p.getCategory());
            ps.setString(4, p.getAuthor());
            int n = ps.executeUpdate();
            if (n == 1) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return -1;
    }

    public List<Post> list(String category) {
        boolean all = (category == null || "전체".equals(category));
        String sql = all
            ? "SELECT * FROM post ORDER BY id DESC"
            : "SELECT * FROM post WHERE category=? ORDER BY id DESC";

        List<Post> list = new ArrayList<>();
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            if (!all) ps.setString(1, category);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public Post findById(int id) {
        final String sql = "SELECT * FROM post WHERE id=?";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    private Post map(ResultSet rs) throws SQLException {
        Post p = new Post();
        p.setId(rs.getInt("id"));
        p.setTitle(rs.getString("title"));
        p.setContent(rs.getString("content"));
        p.setCategory(rs.getString("category"));
        p.setAuthor(rs.getString("author"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        p.setUpdatedAt(rs.getTimestamp("updated_at"));
        return p;
    }

    @Override public void close() {
        try { if (conn != null && !conn.isClosed()) conn.close(); } catch (SQLException ignore) {}
    }
}
