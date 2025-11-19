package dao;

import dto.Match;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MatchDAO {

    /** 오늘 전체 경기 조회 (취소된 경기 제외) */
    public List<Match> getTodayMatches() {
        List<Match> matches = new ArrayList<>();
        String sql = "SELECT * FROM match_reservations " +
                     "WHERE match_date = CURDATE() " +
                     "AND match_status != '취소됨' " +
                     "ORDER BY match_time";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                matches.add(toMatch(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return matches;
    }

    /** 장소별 오늘 경기 조회 */
    public List<Match> getTodayMatchesByPlace(String place) {
        List<Match> matches = new ArrayList<>();

        String sql = "SELECT * FROM match_reservations " +
                     "WHERE match_date = CURDATE() " +
                     "AND REPLACE(location, ' ', '') LIKE CONCAT('%', REPLACE(?, ' ', ''), '%') " +
                     "AND match_status != '취소됨' " +
                     "ORDER BY match_time";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, place.trim());

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    matches.add(toMatch(rs));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return matches;
    }

    /** 날짜 기준 장소별 경기 조회 */
    public List<Match> getMatchesByPlace(String place, String date) {
        if (date == null || date.isBlank()) {
            return getTodayMatchesByPlace(place);
        }

        List<Match> matches = new ArrayList<>();

        String sql = "SELECT * FROM match_reservations " +
                     "WHERE match_date = ? " +
                     "AND REPLACE(location, ' ', '') LIKE CONCAT('%', REPLACE(?, ' ', ''), '%') " +
                     "AND match_status != '취소됨' " +
                     "ORDER BY match_time";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setDate(1, Date.valueOf(date.trim()));
            pstmt.setString(2, place.trim());

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    matches.add(toMatch(rs));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return matches;
    }

    /** 경기 예약 */
    public boolean bookMatch(int userId, int matchId) {
        String checkSql = "SELECT COUNT(*) FROM reservations WHERE user_id=? AND match_reservation_id=?";
        String getSql = "SELECT current_players, max_players, match_status FROM match_reservations WHERE id=?";
        String insertSql = "INSERT INTO reservations(user_id, match_reservation_id) VALUES (?, ?)";
        String updateSql = "UPDATE match_reservations SET current_players = current_players + 1 WHERE id=?";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            // 중복 체크
            try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                checkStmt.setInt(1, userId);
                checkStmt.setInt(2, matchId);
                try (ResultSet rs = checkStmt.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        return false;
                    }
                }
            }

            // status, 인원 확인
            int current = 0, max = 0;
            String status = null;

            try (PreparedStatement getStmt = conn.prepareStatement(getSql)) {
                getStmt.setInt(1, matchId);
                try (ResultSet rs = getStmt.executeQuery()) {
                    if (rs.next()) {
                        current = rs.getInt("current_players");
                        max = rs.getInt("max_players");
                        status = rs.getString("match_status");
                    } else {
                        return false;
                    }

                    if (!"예약중".equals(status)) return false;
                    if (current >= max) return false;
                }
            }

            // 예약 저장
            try (PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                insertStmt.setInt(1, userId);
                insertStmt.setInt(2, matchId);
                insertStmt.executeUpdate();
            }

            // 인원 증가
            try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                updateStmt.setInt(1, matchId);
                updateStmt.executeUpdate();
            }

            conn.commit();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /** 예약 취소 */
    public boolean cancelReservation(int userId, int matchId) {
        String deleteSql = "DELETE FROM reservations WHERE user_id=? AND match_reservation_id=?";
        String updateSql = "UPDATE match_reservations SET current_players = current_players - 1 " +
                           "WHERE id=? AND current_players > 0";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            int deleted;

            try (PreparedStatement delStmt = conn.prepareStatement(deleteSql)) {
                delStmt.setInt(1, userId);
                delStmt.setInt(2, matchId);
                deleted = delStmt.executeUpdate();
            }

            if (deleted == 0) {
                conn.rollback();
                return false;
            }

            try (PreparedStatement upStmt = conn.prepareStatement(updateSql)) {
                upStmt.setInt(1, matchId);
                upStmt.executeUpdate();
            }

            conn.commit();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /** 경기 ID로 장소명 조회 */
    public String getPlaceByMatchId(int matchId) {
        String sql = "SELECT location FROM match_reservations WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, matchId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getString("location");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /** 특정 사용자가 특정 경기를 예약했는지 여부 */
    public boolean isUserReserved(int userId, int matchId) {
        String sql = "SELECT COUNT(*) FROM reservations WHERE user_id=? AND match_reservation_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

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

    // ===========================================================
    // ⭐⭐ [추가] 내가 예약했던 경기 목록 조회
    // ===========================================================
    public List<Match> listReservedByUser(int userId) {

        List<Match> list = new ArrayList<>();

        String sql = """
            SELECT m.*
            FROM match_reservations m
            JOIN reservations r ON r.match_reservation_id = m.id
            WHERE r.user_id = ?
            ORDER BY m.match_date DESC, m.match_time DESC
        """;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(toMatch(rs));
            }

        } catch (Exception e) { e.printStackTrace(); }

        return list;
    }

    // ===========================================================
    // ⭐⭐ [추가] 리뷰 가능 경기(과거 경기)
    // ===========================================================
    public List<Match> listHistoryByUser(int userId) {

        List<Match> list = new ArrayList<>();

        String sql = """
            SELECT m.*
            FROM match_reservations m
            JOIN reservations r ON r.match_reservation_id = m.id
            WHERE r.user_id = ?
            AND m.match_date < CURDATE()
            ORDER BY m.match_date DESC, m.match_time DESC
        """;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(toMatch(rs));
            }

        } catch (Exception e) { e.printStackTrace(); }

        return list;
    }

    /* =======================================================
         ResultSet → Match 변환
       ======================================================= */
    private Match toMatch(ResultSet rs) throws SQLException {
        Match m = new Match();
        m.setId(rs.getInt("id"));
        m.setMatchTime(rs.getTime("match_time").toLocalTime());
        m.setLocation(rs.getString("location"));
        m.setCurrentPlayers(rs.getInt("current_players"));
        m.setMaxPlayers(rs.getInt("max_players"));
        m.setMatchStatus(rs.getString("match_status"));
        m.setMatchDate(rs.getDate("match_date").toLocalDate());
        return m;
    }

}
