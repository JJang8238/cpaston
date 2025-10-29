package dao;

import util.DBConnection;
import dto.MyReservation;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReservationDAO {

    /** 내가 예약한 경기 목록 */
    public List<MyReservation> findByUserId(int userId) {
        String sql = """
            SELECT r.id AS reservation_id,
                   mr.id AS match_reservation_id,
                   mr.location,
                   DATE_FORMAT(mr.match_date, '%Y-%m-%d') AS match_date,
                   DATE_FORMAT(mr.match_time, '%H:%i')   AS match_time
            FROM reservations r
            JOIN match_reservations mr ON mr.id = r.match_reservation_id
            WHERE r.user_id = ?
            ORDER BY mr.match_date DESC, mr.match_time DESC
        """;

        List<MyReservation> list = new ArrayList<>();
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    MyReservation m = new MyReservation();
                    m.setReservationId(rs.getInt("reservation_id"));
                    m.setMatchReservationId(rs.getInt("match_reservation_id"));
                    m.setLocation(rs.getString("location"));
                    m.setMatchDate(rs.getString("match_date"));
                    m.setMatchTime(rs.getString("match_time"));
                    list.add(m);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /** 이미 해당 경기를 예약했는지 */
    public boolean hasReservation(int userId, int matchId) {
        String sql = "SELECT 1 FROM reservations WHERE user_id=? AND match_reservation_id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, matchId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    /** 현재 인원 조회 */
    public int getCurrentPlayers(int matchId){
        String sql = "SELECT current_players FROM match_reservations WHERE id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, matchId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return -1;
    }

    /** 예약(트랜잭션) : 정원 체크 → 인원 +1 → reservations insert */
    public BookResult book(int userId, int matchId) {
        BookResult r = new BookResult(false, "unknown", -1);
        try (Connection c = DBConnection.getConnection()) {
            c.setAutoCommit(false);

            // 1) 자리가 있을 때만 +1
            try (PreparedStatement up = c.prepareStatement(
                    "UPDATE match_reservations " +
                    "SET current_players = current_players + 1 " +
                    "WHERE id=? AND current_players < max_players")) {
                up.setInt(1, matchId);
                if (up.executeUpdate() == 0) { // 만석
                    r.msg = "full"; c.rollback(); return r;
                }
            }

            // 2) 예약 insert (중복 방지 UNIQUE(user,match))
            try (PreparedStatement ins = c.prepareStatement(
                    "INSERT INTO reservations(user_id, match_reservation_id) VALUES (?,?)")) {
                ins.setInt(1, userId);
                ins.setInt(2, matchId);
                ins.executeUpdate();
            } catch (SQLException ex) {
                // 중복/오류 → 인원 되돌림
                try (PreparedStatement down = c.prepareStatement(
                        "UPDATE match_reservations " +
                        "SET current_players = GREATEST(current_players-1,0) WHERE id=?")) {
                    down.setInt(1, matchId);
                    down.executeUpdate();
                }
                r.msg = (ex.getMessage()!=null && ex.getMessage().contains("uk_user_match")) ? "already" : "error";
                c.rollback(); return r;
            }

            // 3) 현재 인원 조회
            int cur = getCurrentInsideTx(c, matchId);
            c.commit();
            r.ok = true; r.msg = "ok"; r.currentPlayers = cur;
        } catch (Exception e) { e.printStackTrace(); }
        return r;
    }

    /** 예약 취소(트랜잭션) : reservations delete → 인원 -1 */
    public BookResult cancel(int userId, int matchId) {
        BookResult r = new BookResult(false, "notfound", -1);
        try (Connection c = DBConnection.getConnection()) {
            c.setAutoCommit(false);

            int deleted;
            try (PreparedStatement del = c.prepareStatement(
                    "DELETE FROM reservations WHERE user_id=? AND match_reservation_id=?")) {
                del.setInt(1, userId);
                del.setInt(2, matchId);
                deleted = del.executeUpdate();
            }
            if (deleted == 0) { c.rollback(); return r; }

            try (PreparedStatement down = c.prepareStatement(
                    "UPDATE match_reservations " +
                    "SET current_players = GREATEST(current_players-1,0) WHERE id=?")) {
                down.setInt(1, matchId);
                down.executeUpdate();
            }

            int cur = getCurrentInsideTx(c, matchId);
            c.commit();
            r.ok = true; r.msg = "ok"; r.currentPlayers = cur;
        } catch (Exception e) { e.printStackTrace(); }
        return r;
    }

    /* --- 내부 유틸 --- */
    private int getCurrentInsideTx(Connection c, int matchId) throws SQLException {
        try (PreparedStatement sel = c.prepareStatement(
                "SELECT current_players FROM match_reservations WHERE id=?")) {
            sel.setInt(1, matchId);
            try (ResultSet rs = sel.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return -1;
    }

    /** 컨트롤러 응답용 결과 */
    public static class BookResult {
        public boolean ok; public String msg; public int currentPlayers;
        public BookResult(boolean ok, String msg, int cur){ this.ok=ok; this.msg=msg; this.currentPlayers=cur; }
    }
}
