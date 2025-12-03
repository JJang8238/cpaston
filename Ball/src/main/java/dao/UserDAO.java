package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import dto.User;
import util.DBConnection;
import util.PasswordUtil;

public class UserDAO implements AutoCloseable {

    private Connection conn;

    public UserDAO() {
        try {
            conn = DBConnection.getConnection();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /** 안전한 커넥션 보장 */
    private Connection getConn() {
        try {
            if (conn == null || conn.isClosed()) {
                conn = DBConnection.getConnection();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return conn;
    }

    // ================================================================
    // 1) 회원가입
    // ================================================================
    public boolean registerUser(String username, String password, String name, String email) {
        final String sql =
            "INSERT INTO `user` (`username`,`password`,`name`,`email`,`email_verified`,`role`) " +
            "VALUES (?, ?, ?, ?, ?, 'users')";

        try (PreparedStatement pstmt = getConn().prepareStatement(sql)) {
            String hashedPassword = PasswordUtil.hashPassword(password);

            pstmt.setString(1, username);
            pstmt.setString(2, hashedPassword);
            pstmt.setString(3, name);
            pstmt.setString(4, email);
            pstmt.setInt(5, (email == null) ? 0 : 1);

            return pstmt.executeUpdate() == 1;

        } catch (SQLIntegrityConstraintViolationException e) {
            System.out.println("❌ 중복된 아이디/이메일: " + username + " / " + email);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ================================================================
    // 2) 로그인
    // ================================================================
    public User login(String username, String password) {
        final String sql = "SELECT * FROM `user` WHERE `username`=? AND `password`=?";
        try (PreparedStatement pstmt = getConn().prepareStatement(sql)) {

            String hashedPassword = PasswordUtil.hashPassword(password);
            pstmt.setString(1, username);
            pstmt.setString(2, hashedPassword);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ================================================================
    // 3) 아이디 중복 확인
    // ================================================================
    public boolean isAvailable(String username) {
        final String sql = "SELECT COUNT(*) FROM `user` WHERE `username`=?";
        try (PreparedStatement pstmt = getConn().prepareStatement(sql)) {
            pstmt.setString(1, username);

            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() && rs.getInt(1) == 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ================================================================
    // 4) 이메일 중복 확인
    // ================================================================
    public boolean isEmailAvailable(String email) {
        final String sql = "SELECT COUNT(*) FROM `user` WHERE `email`=?";
        try (PreparedStatement pstmt = getConn().prepareStatement(sql)) {
            pstmt.setString(1, email);

            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() && rs.getInt(1) == 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ================================================================
    // 5) username으로 조회
    // ================================================================
    public User findByUsername(String username) {
        final String sql = "SELECT * FROM `user` WHERE `username`=?";
        try (PreparedStatement pstmt = getConn().prepareStatement(sql)) {
            pstmt.setString(1, username);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ================================================================
    // 6) email로 조회
    // ================================================================
    public User findByEmail(String email) {
        final String sql = "SELECT * FROM `user` WHERE `email`=?";
        try (PreparedStatement pstmt = getConn().prepareStatement(sql)) {
            pstmt.setString(1, email);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ================================================================
    // 7) username + email (비밀번호 찾기용)
    // ================================================================
    public User findByUsernameAndEmail(String username, String email) {
        final String sql = "SELECT * FROM `user` WHERE `username`=? AND `email`=?";
        try (PreparedStatement pstmt = getConn().prepareStatement(sql)) {
            pstmt.setString(1, username);
            pstmt.setString(2, email);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ================================================================
    // ⭐ 8) name + email 로 조회 (아이디 찾기용) — 새로 추가됨
    // ================================================================
    public User findByNameAndEmail(String name, String email) {
        final String sql = "SELECT * FROM `user` WHERE `name`=? AND `email`=?";
        try (PreparedStatement pstmt = getConn().prepareStatement(sql)) {
            pstmt.setString(1, name);
            pstmt.setString(2, email);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ================================================================
    // 9) 비밀번호 변경
    // ================================================================
    public boolean updatePassword(int userId, String newPassword) {
        final String sql = "UPDATE `user` SET `password`=? WHERE `id`=?";
        try (PreparedStatement pstmt = getConn().prepareStatement(sql)) {

            pstmt.setString(1, PasswordUtil.hashPassword(newPassword));
            pstmt.setInt(2, userId);

            return pstmt.executeUpdate() == 1;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ================================================================
    // 10) 회원정보 수정
    // ================================================================
    public boolean updateUserProfile(User user, String newPassword) {
        StringBuilder sql = new StringBuilder(
            "UPDATE `user` SET `name`=?, `email`=?, `profile_image`=?"
        );

        boolean changePw = newPassword != null && !newPassword.isBlank();
        if (changePw) sql.append(", `password`=?");

        sql.append(" WHERE `id`=?");

        try (PreparedStatement pstmt = getConn().prepareStatement(sql.toString())) {

            pstmt.setString(1, user.getName());
            pstmt.setString(2, user.getEmail());
            pstmt.setString(3, user.getProfileImage());

            int idx = 4;

            if (changePw) {
                pstmt.setString(idx++, PasswordUtil.hashPassword(newPassword));
            }

            pstmt.setInt(idx, user.getId());

            return pstmt.executeUpdate() == 1;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ================================================================
    // 11) 전체 회원 조회
    // ================================================================
    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>();
        final String sql = "SELECT * FROM `user` ORDER BY id DESC";

        try (PreparedStatement pstmt = getConn().prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                User u = new User();
                u.setId(rs.getInt("id"));
                u.setUsername(rs.getString("username"));
                u.setName(rs.getString("name"));
                u.setEmail(rs.getString("email"));
                u.setRole(rs.getString("role"));
                list.add(u);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ================================================================
    // 12) 회원 삭제
    // ================================================================
    public boolean deleteUser(int id) {
        final String sql = "DELETE FROM user WHERE id=?";
        try (PreparedStatement pstmt = getConn().prepareStatement(sql)) {
            pstmt.setInt(1, id);
            return pstmt.executeUpdate() == 1;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ================================================================
    // 13) 권한 변경
    // ================================================================
    public boolean updateUserRole(int id, String role) {
        final String sql = "UPDATE user SET role=? WHERE id=?";
        try (PreparedStatement pstmt = getConn().prepareStatement(sql)) {
            pstmt.setString(1, role);
            pstmt.setInt(2, id);
            return pstmt.executeUpdate() == 1;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ================================================================
    // 공통 매핑
    // ================================================================
    private User mapRow(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setUsername(rs.getString("username"));
        u.setPassword(rs.getString("password"));
        u.setName(rs.getString("name"));
        u.setRole(rs.getString("role"));
        u.setEmail(rs.getString("email"));
        u.setEmailVerified(rs.getInt("email_verified"));
        u.setProfileImage(rs.getString("profile_image"));
        return u;
    }

    // ================================================================
    // 14) close()
    // ================================================================
    @Override
    public void close() {
        try {
            if (conn != null && !conn.isClosed()) conn.close();
        } catch (Exception ignore) {}
    }
}