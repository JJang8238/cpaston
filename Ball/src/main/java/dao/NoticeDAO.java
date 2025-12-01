package dao;

import dto.Notice;
import util.DBConnection;
import java.sql.*;

public class NoticeDAO implements AutoCloseable {

    private Connection conn;

    public NoticeDAO() {
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

    // 🔹 최신 공지 1개 가져오기
    public Notice getLatestNotice() {
        final String sql = "SELECT * FROM notice ORDER BY id DESC LIMIT 1";

        try (PreparedStatement ps = getConn().prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                Notice n = new Notice();
                n.setId(rs.getInt("id"));
                n.setTitle(rs.getString("title"));
                n.setContent(rs.getString("content"));
                n.setCreatedAt(rs.getTimestamp("created_at"));
                return n;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    // 🔹 공지 상세 조회 (팝업에서 사용)
    public Notice findById(int id) {
        final String sql = "SELECT * FROM notice WHERE id = ?";

        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Notice n = new Notice();
                    n.setId(rs.getInt("id"));
                    n.setTitle(rs.getString("title"));
                    n.setContent(rs.getString("content"));
                    n.setCreatedAt(rs.getTimestamp("created_at"));
                    return n;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    // 🔹 공지 새로 등록하기
    public boolean insertNotice(String title, String content) {
        final String sql = "INSERT INTO notice (title, content, created_at) VALUES (?, ?, NOW())";

        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setString(1, title);
            ps.setString(2, content);
            int affected = ps.executeUpdate();
            return affected == 1;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // 🔹 공지 새로 등록하기
    public boolean insertNotice(String title, String content) {
        final String sql = "INSERT INTO notice (title, content, created_at) VALUES (?, ?, NOW())";

        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setString(1, title);
            ps.setString(2, content);
            int affected = ps.executeUpdate();
            return affected == 1;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public void close() {
        try { if (conn != null) conn.close(); } catch (Exception ignore) {}
    }
}
