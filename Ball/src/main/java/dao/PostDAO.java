package dao;

import dto.Post;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PostDAO implements AutoCloseable {

    private Connection conn;

    public PostDAO() {
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

    /* =============================================================
       INSERT
    ============================================================= */
    public int insert(Post p) {
        final String sql =
            "INSERT INTO post(title, content, board_id, author) VALUES (?, ?, ?, ?)";

        try (PreparedStatement ps = getConn().prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, p.getTitle());
            ps.setString(2, p.getContent());
            ps.setInt(3, p.getBoardId());
            ps.setString(4, p.getAuthor());

            int n = ps.executeUpdate();

            if (n == 1) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return -1;
    }

    /* =============================================================
       📌 전체 게시글 조회
    ============================================================= */
    public List<Post> listAll() {
        String sql = "SELECT * FROM post ORDER BY id DESC";
        List<Post> list = new ArrayList<>();

        try (PreparedStatement ps = getConn().prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) list.add(map(rs));

        } catch (Exception e) { e.printStackTrace(); }

        return list;
    }

    /* =============================================================
       📌 문자열 기반 카테고리 조회
    ============================================================= */
    public List<Post> list(String category) {

        List<Post> list = new ArrayList<>();
        String sql;

        if ("전체".equals(category)) {
            return listAll();
        }
        else if ("인기글".equals(category) || "동네질문".equals(category)) {
            sql = "SELECT p.* FROM post p JOIN board b ON p.board_id = b.id "
                + "WHERE b.name = ? ORDER BY p.id DESC";
        }
        else if (category.matches("\\d+")) {
            sql = "SELECT * FROM post WHERE board_id=? ORDER BY id DESC";
        }
        else {
            return listAll();
        }

        try (PreparedStatement ps = getConn().prepareStatement(sql)) {

            if ("인기글".equals(category) || "동네질문".equals(category)) {
                ps.setString(1, category);
            } else if (category.matches("\\d+")) {
                ps.setInt(1, Integer.parseInt(category));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }

        } catch (Exception e) { e.printStackTrace(); }

        return list;
    }

    /* =============================================================
       📌 게시판 ID 기반 조회
    ============================================================= */
    public List<Post> listByBoardId(int boardId) {

        String sql = "SELECT * FROM post WHERE board_id=? ORDER BY id DESC";
        List<Post> list = new ArrayList<>();

        try (PreparedStatement ps = getConn().prepareStatement(sql)) {

            ps.setInt(1, boardId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }

        } catch (Exception e) { e.printStackTrace(); }

        return list;
    }

    /* =============================================================
       📌 관리자 – 신고 기준 조회
    ============================================================= */
    public List<Post> listByReportThreshold(int threshold) {

        String sql =
            "SELECT * FROM post " +
            "WHERE reports >= ? " +
            "ORDER BY reports DESC, id DESC";

        List<Post> list = new ArrayList<>();

        try (PreparedStatement ps = getConn().prepareStatement(sql)) {

            ps.setInt(1, threshold);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }

        } catch (Exception e) { e.printStackTrace(); }

        return list;
    }

    /* =============================================================
       📌 특정 사용자가 게시글 신고했는지 체크
    ============================================================= */
    public boolean didUserReport(int postId, int userId) {

        String sql = "SELECT 1 FROM post_report_log WHERE post_id=? AND user_id=?";

        try (PreparedStatement ps = getConn().prepareStatement(sql)) {

            ps.setInt(1, postId);
            ps.setInt(2, userId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }

        } catch (Exception e) { e.printStackTrace(); }

        return false;
    }

    /* =============================================================
       FIND BY ID
    ============================================================= */
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

    /* =============================================================
       UPDATE
    ============================================================= */
    public int update(Post p) {

        final String sql =
            "UPDATE post SET title=?, content=?, board_id=?, updated_at=NOW() WHERE id=?";

        try (PreparedStatement ps = getConn().prepareStatement(sql)) {

            ps.setString(1, p.getTitle());
            ps.setString(2, p.getContent());
            ps.setInt(3, p.getBoardId());
            ps.setInt(4, p.getId());

            return ps.executeUpdate();

        } catch (Exception e) { e.printStackTrace(); }

        return 0;
    }

    /* =============================================================
       DELETE
    ============================================================= */
    public int deletePost(int id) {

        final String sql = "DELETE FROM post WHERE id=?";

        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate();

        } catch (Exception e) { e.printStackTrace(); }

        return 0;
    }

    /* =============================================================
       👍 좋아요 / 👎 싫어요
    ============================================================= */
    public Post votePost(int postId, int userId, String voteType) {

        if (!"like".equals(voteType) && !"dislike".equals(voteType)) return null;

        try {
            Connection c = getConn();
            c.setAutoCommit(false);

            String currentVote = null;

            final String selectSql =
                "SELECT vote_type FROM post_vote_log WHERE post_id=? AND user_id=? FOR_UPDATE";

            try (PreparedStatement ps = c.prepareStatement(selectSql)) {
                ps.setInt(1, postId);
                ps.setInt(2, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) currentVote = rs.getString("vote_type");
                }
            }

            if (currentVote == null) {
                final String insertSql =
                    "INSERT INTO post_vote_log(post_id, user_id, vote_type) VALUES (?,?,?)";

                try (PreparedStatement ps = c.prepareStatement(insertSql)) {
                    ps.setInt(1, postId);
                    ps.setInt(2, userId);
                    ps.setString(3, voteType);
                    ps.executeUpdate();
                }
            }
            else if (currentVote.equals(voteType)) {
                final String deleteSql =
                    "DELETE FROM post_vote_log WHERE post_id=? AND user_id=?";

                try (PreparedStatement ps = c.prepareStatement(deleteSql)) {
                    ps.setInt(1, postId);
                    ps.setInt(2, userId);
                    ps.executeUpdate();
                }
            }
            else {
                final String updateSql =
                    "UPDATE post_vote_log SET vote_type=? WHERE post_id=? AND user_id=?";

                try (PreparedStatement ps = c.prepareStatement(updateSql)) {
                    ps.setString(1, voteType);
                    ps.setInt(2, postId);
                    ps.setInt(3, userId);
                    ps.executeUpdate();
                }
            }

            int likes = 0, dislikes = 0;

            final String aggSql =
                "SELECT SUM(vote_type='like') AS likes, SUM(vote_type='dislike') AS dislikes "
                    + "FROM post_vote_log WHERE post_id=?";

            try (PreparedStatement ps = c.prepareStatement(aggSql)) {
                ps.setInt(1, postId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        likes = rs.getInt("likes");
                        dislikes = rs.getInt("dislikes");
                    }
                }
            }

            final String updatePost =
                "UPDATE post SET likes=?, dislikes=? WHERE id=?";

            try (PreparedStatement ps = c.prepareStatement(updatePost)) {
                ps.setInt(1, likes);
                ps.setInt(2, dislikes);
                ps.setInt(3, postId);
                ps.executeUpdate();
            }

            c.commit();
            c.setAutoCommit(true);

            Post p = findById(postId);
            return p;

        } catch (Exception e) {
            try { conn.rollback(); } catch (Exception ignore) {}
            e.printStackTrace();
        }

        return null;
    }

    /* =============================================================
       🚨 신고 기능
    ============================================================= */
    public boolean addReport(int postId, int userId) {

        try {
            Connection c = getConn();
            c.setAutoCommit(false);

            String checkSql =
                "SELECT 1 FROM post_report_log WHERE post_id=? AND user_id=? FOR_UPDATE";

            boolean exists = false;

            try (PreparedStatement ps = c.prepareStatement(checkSql)) {
                ps.setInt(1, postId);
                ps.setInt(2, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    exists = rs.next();
                }
            }

            if (exists) {
                c.setAutoCommit(true);
                return false;
            }

            String insertSql =
                "INSERT INTO post_report_log(post_id, user_id) VALUES (?,?)";

            try (PreparedStatement ps = c.prepareStatement(insertSql)) {
                ps.setInt(1, postId);
                ps.setInt(2, userId);
                ps.executeUpdate();
            }

            int reports = 0;

            try (PreparedStatement ps = c.prepareStatement(
                "SELECT COUNT(*) AS cnt FROM post_report_log WHERE post_id=?")) {
                ps.setInt(1, postId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) reports = rs.getInt("cnt");
                }
            }

            try (PreparedStatement ps = c.prepareStatement(
                "UPDATE post SET reports=? WHERE id=?")) {
                ps.setInt(1, reports);
                ps.setInt(2, postId);
                ps.executeUpdate();
            }

            c.commit();
            c.setAutoCommit(true);
            return true;

        } catch (Exception e) {
            try { conn.rollback(); } catch (Exception ignore) {}
            e.printStackTrace();
        }

        return false;
    }

    /* =============================================================
       📌 작성자(author) 기준으로 게시글 조회 (추가된 메서드)
    ============================================================= */
    public List<Post> listByAuthor(String author) {

        String sql = "SELECT * FROM post WHERE author = ? ORDER BY id DESC";
        List<Post> list = new ArrayList<>();

        try (PreparedStatement ps = getConn().prepareStatement(sql)) {

            ps.setString(1, author);

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

    /* =============================================================
       DTO 매핑
    ============================================================= */
    private Post map(ResultSet rs) throws SQLException {

        Post p = new Post();

        p.setId(rs.getInt("id"));
        p.setTitle(rs.getString("title"));
        p.setContent(rs.getString("content"));
        p.setAuthor(rs.getString("author"));
        p.setBoardId(rs.getInt("board_id"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        p.setUpdatedAt(rs.getTimestamp("updated_at"));

        p.setLikes(rs.getInt("likes"));
        p.setDislikes(rs.getInt("dislikes"));
        p.setReports(rs.getInt("reports"));

        return p;
    }

    @Override
    public void close() {
        try {
            if (conn != null && !conn.isClosed()) conn.close();
        } catch (SQLException ignore) {}
    }
}
