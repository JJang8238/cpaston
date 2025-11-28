package dao;

import java.sql.*;
import java.util.*;
import dto.Board;

public class BoardDAO implements AutoCloseable {

    private Connection conn;

    public BoardDAO() throws Exception {
        String url = "jdbc:mysql://localhost:3306/grade_DB?serverTimezone=UTC";
        conn = DriverManager.getConnection(url, "root", "1234");
    }

    // ----------------------------
    // 📌 전체 게시판 ID 자동 탐지
    // ----------------------------
    public int getAllBoardId() throws Exception {
        String sql = "SELECT id FROM board WHERE name='전체' LIMIT 1";

        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) return rs.getInt(1);
        }

        throw new IllegalStateException("'전체' 게시판이 존재하지 않습니다.");
    }

    // ----------------------------
    // 📌 인기글 게시판 ID 자동 탐지
    // ----------------------------
    public int getHotBoardId() throws Exception {
        String sql = "SELECT id FROM board WHERE name='인기글' LIMIT 1";

        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) return rs.getInt(1);
        }

        throw new IllegalStateException("'인기글' 게시판이 존재하지 않습니다.");
    }

    // ----------------------------
    // 📌 고정 게시판인지 여부 판단
    // ----------------------------
    public boolean isFixedBoard(int id) throws Exception {
        int all = getAllBoardId();
        int hot = getHotBoardId();

        return (id == all || id == hot);
    }

    // ----------------------------
    // 전체 목록
    // ----------------------------
    public List<Board> list() throws Exception {
        String sql = "SELECT * FROM board ORDER BY sort_order ASC, id ASC";
        PreparedStatement ps = conn.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();

        List<Board> list = new ArrayList<>();
        while (rs.next()) {
            Board b = new Board();
            b.setId(rs.getInt("id"));
            b.setName(rs.getString("name"));
            b.setSortOrder(rs.getInt("sort_order"));
            list.add(b);
        }
        return list;
    }

    // ----------------------------
    // 전체 게시판 목록
    // ----------------------------
    public List<Board> getAllBoards() throws Exception {

        String sql = "SELECT * FROM board ORDER BY sort_order ASC, id ASC";
        PreparedStatement ps = conn.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();

        List<Board> list = new ArrayList<>();

        while (rs.next()) {
            Board b = new Board();
            b.setId(rs.getInt("id"));
            b.setName(rs.getString("name"));
            b.setSortOrder(rs.getInt("sort_order"));
            list.add(b);
        }

        return list;
    }

    // ----------------------------
    // 단일 조회
    // ----------------------------
    public Board get(int id) throws Exception {
        String sql = "SELECT * FROM board WHERE id=?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, id);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            Board b = new Board();
            b.setId(rs.getInt("id"));
            b.setName(rs.getString("name"));
            b.setSortOrder(rs.getInt("sort_order"));
            return b;
        }
        return null;
    }

    // ----------------------------
    // 추가
    // ----------------------------
    public void insert(String name) throws Exception {
        int maxOrder = 0;
        PreparedStatement psMax = conn.prepareStatement("SELECT MAX(sort_order) FROM board");
        ResultSet rsMax = psMax.executeQuery();
        if (rsMax.next()) maxOrder = rsMax.getInt(1);

        PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO board(name, sort_order) VALUES(?, ?)");

        ps.setString(1, name);
        ps.setInt(2, maxOrder + 1);
        ps.executeUpdate();
    }

    // ----------------------------
    // 수정 (고정 게시판 보호)
    // ----------------------------
    public void update(int id, String name) throws Exception {

        if (isFixedBoard(id)) {
            throw new IllegalStateException("고정 게시판은 이름을 변경할 수 없습니다.");
        }

        PreparedStatement ps = conn.prepareStatement(
                "UPDATE board SET name=? WHERE id=?");
        ps.setString(1, name);
        ps.setInt(2, id);
        ps.executeUpdate();
    }

    // ----------------------------
    // 삭제 (고정 게시판 보호)
    // ----------------------------
    public void delete(int id) throws Exception {

        conn.setAutoCommit(false);

        int allBoardId = getAllBoardId();

        if (isFixedBoard(id)) {
            conn.setAutoCommit(true);
            throw new IllegalStateException("고정 게시판은 삭제할 수 없습니다.");
        }

        // 글 이동 → 전체 게시판으로
        try (PreparedStatement psMove = conn.prepareStatement(
                "UPDATE post SET board_id = ? WHERE board_id = ?")) {
            psMove.setInt(1, allBoardId);
            psMove.setInt(2, id);
            psMove.executeUpdate();
        }

        // 게시판 삭제
        try (PreparedStatement psDel = conn.prepareStatement(
                "DELETE FROM board WHERE id = ?")) {
            psDel.setInt(1, id);
            psDel.executeUpdate();
        }

        // 정렬 재배치
        normalizeSortOrder();

        conn.commit();
        conn.setAutoCommit(true);
    }

    // ----------------------------
    // 정렬 재정렬
    // ----------------------------
    private void normalizeSortOrder() throws Exception {
        String sql =
            "UPDATE board " +
            "JOIN (" +
            "   SELECT id, ROW_NUMBER() OVER (ORDER BY sort_order ASC, id ASC) AS rn " +
            "   FROM board" +
            ") AS t ON board.id = t.id " +
            "SET board.sort_order = t.rn";

        Statement st = conn.createStatement();
        st.executeUpdate(sql);
    }

    // ----------------------------
    // 드래그앤드롭 정렬 (고정 게시판 보호)
    // ----------------------------
    public void updateSortOrder(String[] idList) throws Exception {

        // ★ 고정 게시판 이동 금지
        for (String idStr : idList) {
            int id = Integer.parseInt(idStr);
            if (isFixedBoard(id)) {
                throw new IllegalStateException("고정 게시판의 순서는 변경할 수 없습니다.");
            }
        }

        String sql = "UPDATE board SET sort_order = ? WHERE id = ?";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {

            int sortIndex = 1;

            for (String idStr : idList) {
                int id = Integer.parseInt(idStr);

                pstmt.setInt(1, sortIndex++);
                pstmt.setInt(2, id);
                pstmt.addBatch();
            }

            pstmt.executeBatch();
        }
    }

    @Override
    public void close() throws Exception {
        if (conn != null) conn.close();
    }
}
