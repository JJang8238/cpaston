package dao;

import java.sql.*;
import java.util.*;
import dto.Board;

public class BoardDAO implements AutoCloseable {

    private Connection conn;

    // ----------------------------------------------------
    // 🔥 DB 연결 (AWS RDS)
    // ----------------------------------------------------
    public BoardDAO() {
        try {
            String url = "jdbc:mysql://database-1.cr6syquwsi52.ap-northeast-2.rds.amazonaws.com:3306/grade_db"
                       + "?useUnicode=true&characterEncoding=utf8"
                       + "&serverTimezone=Asia/Seoul&useSSL=true&allowPublicKeyRetrieval=true";

            System.out.println("📌 BoardDAO: DB 연결 시도 → " + url);

            conn = DriverManager.getConnection(url, "admin", "wkdtpguS9162");

            System.out.println("✅ BoardDAO: DB 연결 성공");

            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT DATABASE()")) {
                if (rs.next()) {
                    System.out.println("📌 현재 접속 DB = " + rs.getString(1));
                }
            }

        } catch (Exception e) {
            System.out.println("❌ BoardDAO: DB 연결 실패");
            e.printStackTrace();
        }
    }

    private Connection getConn() throws Exception {
        if (conn == null || conn.isClosed()) {
            String url = "jdbc:mysql://database-1.cr6syquwsi52.ap-northeast-2.rds.amazonaws.com:3306/grade_db"
                       + "?useUnicode=true&characterEncoding=utf8"
                       + "&serverTimezone=Asia/Seoul&useSSL=true&allowPublicKeyRetrieval=true";

            conn = DriverManager.getConnection(url, "admin", "👉여기에_RDS비밀번호_넣기👈");
        }
        return conn;
    }

    // ----------------------------------------------------
    // 📌 전체/인기글 ID
    // ----------------------------------------------------
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

    // ----------------------------------------------------
    // 📌 목록
    // ----------------------------------------------------
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

    // ----------------------------------------------------
    // 📌 단일 조회
    // ----------------------------------------------------
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

    // ----------------------------------------------------
    // 📌 추가
    // ----------------------------------------------------
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

    // ----------------------------------------------------
    // 📌 삭제
    // ----------------------------------------------------
    public boolean delete(int id) {

        if (isFixedBoard(id)) {
            System.out.println("❌ 기본 게시판 삭제 불가");
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

    // ----------------------------------------------------
    // 📌 정렬순서 업데이트
    // ----------------------------------------------------
    public boolean updateSortOrder(String[] idArr) {

        System.out.println("📌 updateSortOrder 호출 — 배열 길이: " + idArr.length);

        String sql = "UPDATE board SET sort_order=? WHERE id=?";

        try (PreparedStatement ps = getConn().prepareStatement(sql)) {

            int order = 1;

            for (String idStr : idArr) {

                int id = Integer.parseInt(idStr);

                ps.setInt(1, order);
                ps.setInt(2, id);
                ps.addBatch();

                order++;
            }

            ps.executeBatch();

            System.out.println("✔ updateSortOrder 적용 완료");

            return true;

        } catch (Exception e) {
            System.out.println("❌ updateSortOrder 실패");
            e.printStackTrace();
        }

        return false;
    }

    // ----------------------------------------------------
    // 📌 연결 종료
    // ----------------------------------------------------
    @Override
    public void close() {
        try {
            if (conn != null && !conn.isClosed()) {
                conn.close();
            }
        } catch (Exception ignore) {}
    }
}