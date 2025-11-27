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

    // 최신 공지 1개 가져오기
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

        return null; // 공지 없음
    }

    @Override
    public void close() {
        try { if (conn != null) conn.close(); } catch (Exception ignore) {}
    }
}
