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

    // INSERT
    public int insert(Post p) {
        final String sql =
                "INSERT INTO post(title, content, category, author) VALUES (?, ?, ?, ?)";

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
        } catch (Exception e) {
            e.printStackTrace();
        }

        return -1;
    }

    // 목록 조회
    public List<Post> list(String category) {

        String base = "SELECT * FROM post";
        String order =
                " ORDER BY " +
                " CASE WHEN likes >= 5 AND dislikes <= 3 THEN 1 ELSE 0 END DESC, " +
                " (likes - dislikes) DESC, " +
                " id DESC";

        String sql;
        boolean bindCategory = false;

        if ("동네질문".equals(category)) {
            sql = base + " WHERE category=?" + order;
            bindCategory = true;
        } else if ("인기글".equals(category)) {
            sql = base + " WHERE likes >= 5 AND dislikes <= 3" + order;
        } else {
            sql = base + order;
        }

        List<Post> list = new ArrayList<>();

        try (PreparedStatement ps = getConn().prepareStatement(sql)) {

            if (bindCategory) {
                ps.setString(1, category);
            }

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

    // FIND BY ID
    public Post findById(int id) {

        final String sql = "SELECT * FROM post WHERE id=?";

        try (PreparedStatement ps = getConn().prepareStatement(sql)) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    // UPDATE
    public int update(Post p) {
        final String sql =
                "UPDATE post SET title=?, content=?, category=?, updated_at=NOW() WHERE id=?";

        try (PreparedStatement ps = getConn().prepareStatement(sql)) {

            ps.setString(1, p.getTitle());
            ps.setString(2, p.getContent());
            ps.setString(3, p.getCategory());
            ps.setInt(4, p.getId());

            return ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    // DELETE
    public int deletePost(int id) {

        final String sql = "DELETE FROM post WHERE id=?";

        try (PreparedStatement ps = getConn().prepareStatement(sql)) {

            ps.setInt(1, id);

            return ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    // LIST BY AUTHOR
    public List<Post> listByAuthor(String author) {

        final String sql = "SELECT * FROM post WHERE author=? ORDER BY id DESC";

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

    // -------------------------------------------------------------------------
    // 좋아요/싫어요 토글
    // -------------------------------------------------------------------------
    public Post votePost(int postId, int userId, String voteType) {
        if (!"like".equals(voteType) && !"dislike".equals(voteType)) {
            return null;
        }

        try {
            Connection c = getConn();
            c.setAutoCommit(false);

            String currentVote = null;

            // 1) 기존 투표 확인 (잠금)
            final String selectSql =
                    "SELECT vote_type FROM post_vote_log WHERE post_id=? AND user_id=? FOR UPDATE";

            try (PreparedStatement ps = c.prepareStatement(selectSql)) {
                ps.setInt(1, postId);
                ps.setInt(2, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) currentVote = rs.getString("vote_type");
                }
            }

            // 2) 토글 처리
            if (currentVote == null) {
                final String insertSql =
                        "INSERT INTO post_vote_log(post_id, user_id, vote_type) VALUES(?,?,?)";
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

            // 3) 집계
            int likes = 0;
            int dislikes = 0;

            final String aggSql =
                    "SELECT SUM(vote_type='like') AS likes, SUM(vote_type='dislike') AS dislikes " +
                    "FROM post_vote_log WHERE post_id=?";

            try (PreparedStatement ps = c.prepareStatement(aggSql)) {
                ps.setInt(1, postId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        likes = rs.getInt("likes");
                        dislikes = rs.getInt("dislikes");
                    }
                }
            }

            // 4) post 테이블 갱신
            final String updateCountSql =
                    "UPDATE post SET likes=?, dislikes=? WHERE id=?";
            try (PreparedStatement ps = c.prepareStatement(updateCountSql)) {
                ps.setInt(1, likes);
                ps.setInt(2, dislikes);
                ps.setInt(3, postId);
                ps.executeUpdate();
            }

            c.commit();
            c.setAutoCommit(true);

            Post p = new Post();
            p.setId(postId);
            p.setLikes(likes);
            p.setDislikes(dislikes);
            return p;

        } catch (Exception e) {
            try { if (conn != null) conn.rollback(); } catch (Exception ignore) {}
            e.printStackTrace();
        } finally {
            try { if (conn != null) conn.setAutoCommit(true); } catch (Exception ignore) {}
        }

        return null;
    }

    // -------------------------------------------------------------------------
    // 🚨 신고 기능
    // -------------------------------------------------------------------------
    public boolean addReport(int postId, int userId) {

        try {
            Connection c = getConn();
            c.setAutoCommit(false);

            // 1) 기존 신고 여부 확인
            String checkSql =
                    "SELECT 1 FROM post_report_log WHERE post_id=? AND user_id=? FOR UPDATE";

            boolean exists = false;

            try (PreparedStatement ps = c.prepareStatement(checkSql)) {
                ps.setInt(1, postId);
                ps.setInt(2, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    exists = rs.next(); // 이미 신고됨
                }
            }

            if (exists) {
                c.setAutoCommit(true);
                return false;
            }

            // 2) 신고 기록 추가
            String insertSql =
                    "INSERT INTO post_report_log(post_id, user_id) VALUES (?,?)";

            try (PreparedStatement ps = c.prepareStatement(insertSql)) {
                ps.setInt(1, postId);
                ps.setInt(2, userId);
                ps.executeUpdate();
            }

            // 3) 신고수 계산
            int reports = 0;
            String countSql =
                    "SELECT COUNT(*) AS cnt FROM post_report_log WHERE post_id=?";

            try (PreparedStatement ps = c.prepareStatement(countSql)) {
                ps.setInt(1, postId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) reports = rs.getInt("cnt");
                }
            }

            // 4) post 테이블 반영
            String updatePost =
                    "UPDATE post SET reports=? WHERE id=?";

            try (PreparedStatement ps = c.prepareStatement(updatePost)) {
                ps.setInt(1, reports);
                ps.setInt(2, postId);
                ps.executeUpdate();
            }

            c.commit();
            c.setAutoCommit(true);
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            try { conn.rollback(); } catch (Exception ignore) {}
        } finally {
            try { conn.setAutoCommit(true); } catch (Exception ignore) {}
        }

        return false;
    }
 // -------------------------------------------------------------------------
 // 🚨 신고 기준 이상 게시글 목록 조회
 // -------------------------------------------------------------------------
 public List<Post> listByReportThreshold(int threshold) {

     final String sql =
             "SELECT * FROM post WHERE reports >= ? ORDER BY reports DESC, id DESC";

     List<Post> list = new ArrayList<>();

     try (PreparedStatement ps = getConn().prepareStatement(sql)) {

         ps.setInt(1, threshold);

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

    // -------------------------------------------------------------------------
    // DTO 변환
    // -------------------------------------------------------------------------
    private Post map(ResultSet rs) throws SQLException {

        Post p = new Post();

        p.setId(rs.getInt("id"));
        p.setTitle(rs.getString("title"));
        p.setContent(rs.getString("content"));
        p.setCategory(rs.getString("category"));
        p.setAuthor(rs.getString("author"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        p.setUpdatedAt(rs.getTimestamp("updated_at"));

        try {
            p.setLikes(rs.getInt("likes"));
        } catch (SQLException ignore) {}

        try {
            p.setDislikes(rs.getInt("dislikes"));
        } catch (SQLException ignore) {}

        try {
            p.setReports(rs.getInt("reports"));
        } catch (SQLException ignore) {}

        return p;
    }

    @Override
    public void close() {
        try {
            if (conn != null && !conn.isClosed()) conn.close();
        } catch (SQLException ignore) {}
    }
}

