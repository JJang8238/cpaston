package dao;

import java.sql.*;
import java.util.*;
import dto.Board;

public class BoardDAO implements AutoCloseable {

    private Connection conn;

    public BoardDAO() {
        try {
            String url = "jdbc:mysql://database-1.cr6syquwsi52.ap-northeast-2.rds.amazonaws.com:3306/grade_db"
                       + "?useUnicode=true&characterEncoding=utf8"
                       + "&serverTimezone=Asia/Seoul&useSSL=true&allowPublicKeyRetrieval=true";

            conn = DriverManager.getConnection(url, "admin", "wkdtpguS9162");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private Connection getConn() throws Exception {
        if (conn == null || conn.isClosed()) {
            String url = "jdbc:mysql://database-1.cr6syquwsi52.ap-northeast-2.rds.amazonaws.com:3306/grade_db"
                       + "?useUnicode=true&characterEncoding=utf8"
                       + "&serverTimezone=Asia/Seoul&useSSL=true&allowPublicKeyRetrieval=true";
            conn = DriverManager.getConnection(url, "admin", "wkdtpguS9162");
        }
        return conn;
    }

    // 기본 게시판 ID
    public int getAllBoardId() {
        String sql = "SELECT id FROM board WHERE name='전체' LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {}
        return 1;
    }

    public int getHotBoardId() {
        String sql = "SELECT id FROM board WHERE name='인기글' LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {}
        return 2;
    }

    public boolean isFixedBoard(int id) {
        return (id == getAllBoardId() || id == getHotBoardId());
    }

    // 목록
    public List<Board> list() {
        List<Board> list = new ArrayList<>();
        String sql = "SELECT * FROM board ORDER BY sort_order ASC, id ASC";

        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Board b = new Board();
                b.setId(rs.getInt("id"));
                b.setName(rs.getString("name"));
                b.setSortOrder(rs.getInt("sort_order"));
                list.add(b);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // 단일 조회
    public Board get(int id) {
        String sql = "SELECT * FROM board WHERE id=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Board b = new Board();
                    b.setId(rs.getInt("id"));
                    b.setName(rs.getString("name"));
                    b.setSortOrder(rs.getInt("sort_order"));
                    return b;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    // 추가
    public void insert(String name) {
        try {
            int maxOrder = 0;

            try (PreparedStatement ps = conn.prepareStatement("SELECT MAX(sort_order) FROM board");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) maxOrder = rs.getInt(1);
            }

            try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO board(name, sort_order) VALUES(?, ?)")) {

                ps.setString(1, name);
                ps.setInt(2, maxOrder + 1);
                ps.executeUpdate();
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 삭제
    public boolean delete(int id) {

        if (isFixedBoard(id)) {
            return false;
        }

        String sql = "DELETE FROM board WHERE id=?";

        try (PreparedStatement ps = getConn().prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // 정렬순서 변경
    public boolean updateSortOrder(String[] idArr) {

        String sql = "UPDATE board SET sort_order=? WHERE id=?";

        try (PreparedStatement ps = getConn().prepareStatement(sql)) {

            int order = 1;

            for (String idStr : idArr) {
                int id = Integer.parseInt(idStr);
                ps.setInt(1, order++);
                ps.setInt(2, id);
                ps.addBatch();
            }

            ps.executeBatch();

            return true;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // 🔥 게시판 이름 수정 (추가된 부분)
    public int updateBoardName(int id, String newName) {
        String sql = "UPDATE board SET name=? WHERE id=?";
        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setString(1, newName);
            ps.setInt(2, id);
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public void close() {
        try {
            if (conn != null && !conn.isClosed()) {
                conn.close();
            }
        } catch (Exception ignore) {}
    }
}
