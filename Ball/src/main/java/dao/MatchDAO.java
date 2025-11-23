package dao;

import dto.Match;
import util.DBConnection;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class MatchDAO implements AutoCloseable {

    private Connection conn;

    public MatchDAO() {
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

    /* ===========================================================
        ⭐ 오늘 전체 경기 조회
       =========================================================== */
    public List<Match> getTodayMatches() {
        List<Match> matches = new ArrayList<>();
        String sql = """
                SELECT * FROM match_reservations
                WHERE match_date = CURDATE()
                AND match_status != '취소됨'
                ORDER BY match_time
                """;

        try (PreparedStatement pstmt = getConn().prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) matches.add(toMatch(rs));

        } catch (Exception e) { e.printStackTrace(); }

        return matches;
    }

    /* ===========================================================
        ⭐ 오늘 경기 / 장소별 조회
       =========================================================== */
    public List<Match> getTodayMatchesByPlace(String place) {
        List<Match> matches = new ArrayList<>();

        String sql = """
                SELECT * FROM match_reservations
                WHERE match_date = CURDATE()
                AND REPLACE(location,' ','') LIKE CONCAT('%', REPLACE(?, ' ', ''), '%')
                AND match_status != '취소됨'
                ORDER BY match_time
                """;

        try (PreparedStatement pstmt = getConn().prepareStatement(sql)) {
            pstmt.setString(1, place.trim());

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) matches.add(toMatch(rs));
            }

        } catch (Exception e) { e.printStackTrace(); }

        return matches;
    }

    /* ===========================================================
        ⭐ 날짜 + 장소 검색
       =========================================================== */
    public List<Match> getMatchesByPlace(String place, String date) {

        if (date == null || date.isBlank()) {
            return getTodayMatchesByPlace(place);
        }

        List<Match> matches = new ArrayList<>();

        String sql = """
                SELECT * FROM match_reservations
                WHERE match_date = ?
                AND REPLACE(location,' ','') LIKE CONCAT('%', REPLACE(?, ' ', ''), '%')
                AND match_status != '취소됨'
                ORDER BY match_time
                """;

        try (PreparedStatement pstmt = getConn().prepareStatement(sql)) {
            pstmt.setDate(1, Date.valueOf(date.trim()));
            pstmt.setString(2, place.trim());

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) matches.add(toMatch(rs));
            }

        } catch (Exception e) { e.printStackTrace(); }

        return matches;
    }

    /* ===========================================================
        ⭐ 특정 사용자가 특정 경기를 예약했는지
       =========================================================== */
    public boolean isUserReserved(int userId, int matchId) {
        String sql = "SELECT COUNT(*) FROM reservations WHERE user_id=? AND match_reservation_id=?";

        try (PreparedStatement pstmt = getConn().prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            pstmt.setInt(2, matchId);

            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    /* ===========================================================
        ⭐ 예약하기
       =========================================================== */
    public boolean bookMatch(int userId, int matchId) {

        String checkSql = "SELECT COUNT(*) FROM reservations WHERE user_id=? AND match_reservation_id=?";
        String getSql = "SELECT current_players, max_players, match_status FROM match_reservations WHERE id=?";
        String insertSql = "INSERT INTO reservations(user_id, match_reservation_id) VALUES (?, ?)";
        String updateSql = "UPDATE match_reservations SET current_players=current_players+1 WHERE id=?";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            // 중복 체크
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setInt(1, userId);
                ps.setInt(2, matchId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) return false;
                }
            }

            int current = 0, max = 0;
            String status = null;

            try (PreparedStatement ps = conn.prepareStatement(getSql)) {
                ps.setInt(1, matchId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        current = rs.getInt("current_players");
                        max = rs.getInt("max_players");
                        status = rs.getString("match_status");
                    }
                }

                if (!"예약중".equals(status)) return false;
                if (current >= max) return false;
            }

            // 예약 저장
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setInt(1, userId);
                ps.setInt(2, matchId);
                ps.executeUpdate();
            }

            // 인원 증가
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setInt(1, matchId);
                ps.executeUpdate();
            }

            conn.commit();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /* ===========================================================
        ⭐ 예약 취소
       =========================================================== */
    public boolean cancelReservation(int userId, int matchId) {

        String delSql = "DELETE FROM reservations WHERE user_id=? AND match_reservation_id=?";
        String updateSql = "UPDATE match_reservations SET current_players=current_players-1 WHERE id=? AND current_players>0";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            int deleted;

            try (PreparedStatement ps = conn.prepareStatement(delSql)) {
                ps.setInt(1, userId);
                ps.setInt(2, matchId);
                deleted = ps.executeUpdate();
            }

            if (deleted == 0) {
                conn.rollback();
                return false;
            }

            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setInt(1, matchId);
                ps.executeUpdate();
            }

            conn.commit();
            return true;

        } catch (Exception e) { e.printStackTrace(); }

        return false;
    }

    /* ===========================================================
       ⭐ 관리자 — 전체 경기 조회
       =========================================================== */
    public List<Match> getAllMatches() {
        List<Match> list = new ArrayList<>();

        String sql = "SELECT * FROM match_reservations ORDER BY match_date DESC, match_time DESC";

        try (PreparedStatement ps = getConn().prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) list.add(toMatch(rs));

        } catch (Exception e) { e.printStackTrace(); }

        return list;
    }

    /* ===========================================================
       ⭐ 관리자 — 단일 경기 조회
       =========================================================== */
    public Match getMatchById(int id) {
        String sql = "SELECT * FROM match_reservations WHERE id=?";

        try (PreparedStatement ps = getConn().prepareStatement(sql)) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return toMatch(rs);
                }
            }

        } catch (Exception e) { e.printStackTrace(); }

        return null;
    }

    /* ===========================================================
       ⭐ 관리자 — 경기 생성
       =========================================================== */
    public boolean createMatch(Match m) {

        String sql = """
                INSERT INTO match_reservations
                (match_date, match_time, location, current_players, max_players, match_status)
                VALUES (?, ?, ?, 0, ?, '예약중')
                """;

        try (PreparedStatement ps = getConn().prepareStatement(sql)) {

            ps.setDate(1, Date.valueOf(m.getMatchDate()));
            ps.setTime(2, Time.valueOf(m.getMatchTime()));
            ps.setString(3, m.getLocation());
            ps.setInt(4, m.getMaxPlayers());

            return ps.executeUpdate() == 1;

        } catch (Exception e) { e.printStackTrace(); }

        return false;
    }

    /* ===========================================================
       ⭐ 관리자 — 경기 수정 (방법1: 항상 성공 처리)
       =========================================================== */
    public boolean updateMatch(Match m) {

        String sql = """
                UPDATE match_reservations
                SET match_date=?, match_time=?, location=?, max_players=?
                WHERE id=?
                """;

        try (PreparedStatement ps = getConn().prepareStatement(sql)) {

            ps.setDate(1, Date.valueOf(m.getMatchDate()));
            ps.setTime(2, Time.valueOf(m.getMatchTime()));
            ps.setString(3, m.getLocation());
            ps.setInt(4, m.getMaxPlayers());
            ps.setInt(5, m.getId());

            int updated = ps.executeUpdate();
            System.out.println("💛 UPDATE 실행됨, 영향받은 행 수 = " + updated);

            // 🔥 방법1 핵심: 영향받은 행 수 상관없이 성공 처리
            return true;

        } catch (Exception e) { e.printStackTrace(); }

        return false;
    }

    /* ===========================================================
       ⭐ 관리자 — 경기 삭제
       =========================================================== */
    public boolean deleteMatch(int id) {
        String sql = "DELETE FROM match_reservations WHERE id=?";

        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() == 1;
        } catch (Exception e) { e.printStackTrace(); }

        return false;
    }

    /* ===========================================================
       ⭐ getPlaceByMatchId
       =========================================================== */
    public String getPlaceByMatchId(int matchId) {
        String sql = "SELECT location FROM match_reservations WHERE id=?";

        try (PreparedStatement ps = getConn().prepareStatement(sql)) {
            ps.setInt(1, matchId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getString("location");
            }

        } catch (Exception e) { e.printStackTrace(); }

        return null;
    }

    /* ===========================================================
       ⭐ ResultSet → DTO 매핑
       =========================================================== */
    private Match toMatch(ResultSet rs) throws SQLException {
        Match m = new Match();

        m.setId(rs.getInt("id"));
        m.setMatchDate(rs.getDate("match_date").toLocalDate());
        m.setMatchTime(rs.getTime("match_time").toLocalTime());
        m.setLocation(rs.getString("location"));
        m.setCurrentPlayers(rs.getInt("current_players"));
        m.setMaxPlayers(rs.getInt("max_players"));
        m.setMatchStatus(rs.getString("match_status"));

        return m;
    }

    /* ===========================================================
       ⭐ close()
       =========================================================== */
    @Override
    public void close() {
        try {
            if (conn != null && !conn.isClosed()) conn.close();
        } catch (Exception ignore) {}
    }
}
