package dao;

import java.sql.*;
import java.util.*;
import dto.Board;

public class BoardDAO implements AutoCloseable {

    private Connection conn;

    // ----------------------------------------------------
    // 🔥 DB 연결 — 콘솔 출력 추가
    // ----------------------------------------------------
    public BoardDAO() {
        try {
            String url = "jdbc:mysql://localhost:3306/grade_db?serverTimezone=UTC";
            System.out.println("📌 BoardDAO: DB 연결 시도 → " + url);

            conn = DriverManager.getConnection(url, "root", "8238");

            System.out.println("✅ BoardDAO: DB 연결 성공");
            
            try (Statement st = conn.createStatement();
            	     ResultSet rs = st.executeQuery("SELECT DATABASE()")) {
            	    if (rs.next()) {
            	        System.out.println("📌 현재 DAO가 접속한 DB = " + rs.getString(1));
            	    }
            	}

        } catch (Exception e) {
            System.out.println("❌ BoardDAO: DB 연결 실패");
            e.printStackTrace();
        }
    }

    private Connection getConn() throws Exception {
        if (conn == null || conn.isClosed()) {
            String url = "jdbc:mysql://localhost:3306/grade_db?serverTimezone=UTC";
            System.out.println("📌 BoardDAO: 연결 재시도 → " + url);
            conn = DriverManager.getConnection(url, "root", "8238");
        }
        return conn;
    }

    // ----------------------------------------------------
    // 📌 "전체" 게시판 ID
    // ----------------------------------------------------
    public int getAllBoardId() {
        String sql = "SELECT id FROM board WHERE name='전체' LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                System.out.println("✔ getAllBoardId: 전체 ID = " + rs.getInt(1));
                return rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        System.out.println("⚠ getAllBoardId: 기본값 1 반환");
        return 1;
    }

    // ----------------------------------------------------
    // 📌 "인기글" 게시판 ID
    // ----------------------------------------------------
    public int getHotBoardId() {
        String sql = "SELECT id FROM board WHERE name='인기글' LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                System.out.println("✔ getHotBoardId: 인기글 ID = " + rs.getInt(1));
                return rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        System.out.println("⚠ getHotBoardId: 기본값 2 반환");
        return 2;
    }

    // ----------------------------------------------------
    // 📌 고정 게시판 여부
    // ----------------------------------------------------
    public boolean isFixedBoard(int id) {
        boolean fixed = (id == getAllBoardId() || id == getHotBoardId());
        System.out.println("📌 isFixedBoard(" + id + ") = " + fixed);
        return fixed;
    }

    // ----------------------------------------------------
    // 📌 전체 게시판 목록
    // ----------------------------------------------------
    public List<Board> list() {

        List<Board> list = new ArrayList<>();

        String sql = "SELECT * FROM board ORDER BY sort_order ASC, id ASC";

        System.out.println("📌 BoardDAO.list() 실행");

        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Board b = new Board();
                b.setId(rs.getInt("id"));
                b.setName(rs.getString("name"));
                b.setSortOrder(rs.getInt("sort_order"));
                list.add(b);

                System.out.println("→ 로딩됨: ID=" + b.getId() + ", name=" + b.getName());
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        System.out.println("📌 BoardDAO.list(): 총 " + list.size() + "개 로드됨");

        return list;
    }

    // ----------------------------------------------------
    // 📌 단일 조회
    // ----------------------------------------------------
    public Board get(int id) {

        String sql = "SELECT * FROM board WHERE id=?";

        System.out.println("📌 BoardDAO.get(" + id + ") 호출");

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Board b = new Board();
                    b.setId(rs.getInt("id"));
                    b.setName(rs.getString("name"));
                    b.setSortOrder(rs.getInt("sort_order"));

                    System.out.println("✔ BoardDAO.get(): " + b.getName());
                    return b;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        System.out.println("⚠ BoardDAO.get(): 없음");
        return null;
    }

    // ----------------------------------------------------
    // 📌 게시판 추가
    // ----------------------------------------------------
    public void insert(String name) {

        System.out.println("📌 BoardDAO.insert(): name = " + name);

        try {
            int maxOrder = 0;

            try (PreparedStatement psMax = conn.prepareStatement("SELECT MAX(sort_order) FROM board");
                 ResultSet rsMax = psMax.executeQuery()) {

                if (rsMax.next()) maxOrder = rsMax.getInt(1);
            }

            try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO board(name, sort_order) VALUES(?, ?)")) {

                ps.setString(1, name);
                ps.setInt(2, maxOrder + 1);

                ps.executeUpdate();
            }

            System.out.println("✔ BoardDAO.insert() 완료");

        } catch (Exception e) {
            System.out.println("❌ BoardDAO.insert() 실패");
            e.printStackTrace();
        }
    }

    // ----------------------------------------------------
    // 삭제 / 수정은 동일하게 로그 추가 가능
    // ----------------------------------------------------

    @Override
    public void close() {
        try {
            if (conn != null && !conn.isClosed()) {
                System.out.println("✔ BoardDAO: DB 연결 종료");
                conn.close();
            }
        } catch (Exception ignore) {}
    }
}
