package dao;

import dto.Match;
import util.DBConnection;
import java.sql.*;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

public class MatchDAO {

    public List<Match> getTodayMatches() {
        List<Match> matches = new ArrayList<>();
        String sql = "SELECT * FROM match_reservations ORDER BY match_time";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                Match m = new Match();
                m.setId(rs.getInt("id"));
                m.setMatchTime(rs.getTime("match_time").toLocalTime());
                m.setLocation(rs.getString("location"));
                m.setCurrentPlayers(rs.getInt("current_players"));
                m.setMaxPlayers(rs.getInt("max_players"));
                matches.add(m);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return matches;
    }
}
