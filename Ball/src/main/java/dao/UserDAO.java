package dao;

import java.sql.*;
import dto.User;
import util.DBConnection;
import util.PasswordUtil;  // SHA-256 해시 유틸

public class UserDAO implements AutoCloseable {

    private Connection conn;

    public UserDAO() {
        try {
            conn = DBConnection.getConnection();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /** 커넥션이 null/closed면 재연결해서 반환 */
    private Connection getConn() throws Exception {
        if (conn == null || conn.isClosed()) {
            conn = DBConnection.getConnection();
        }
        return conn;
    }

    // ----------------------------------------------------------------
    // 1) 회원가입 (기존 시그니처 유지) - 이메일 없이 쓰던 코드와의 호환
    //    -> 내부에서 email=null 로 호출 (권장: 아래 1-2 메서드 사용)
    // ----------------------------------------------------------------
    @Deprecated
    public boolean registerUser(String username, String password, String name) {
        return registerUser(username, password, name, null);
    }

    // ----------------------------------------------------------------
    // 1-2) 회원가입 (이메일 포함, 이메일 인증 완료 후 호출)
    //      email_verified = 1 로 저장
    // ----------------------------------------------------------------
    public boolean registerUser(String username, String password, String name, String email) {
        final String sql =
            "INSERT INTO `user` " +
            "(`username`,`password`,`name`,`email`,`email_verified`,`role`) " +
            "VALUES (?, ?, ?, ?, ?, 'student')";

        try (PreparedStatement pstmt = getConn().prepareStatement(sql)) {
            String hashedPassword = PasswordUtil.hashPassword(password); // SHA-256

            pstmt.setString(1, username);
            pstmt.setString(2, hashedPassword);
            pstmt.setString(3, name);
            pstmt.setString(4, email);                 // 스키마가 NULL 허용인 경우만 null 가능
            pstmt.setInt(5, (email == null) ? 0 : 1);  // 이메일 인증 완료 후 가입이면 1

            return pstmt.executeUpdate() == 1;
        } catch (SQLIntegrityConstraintViolationException e) {
            System.out.println("❌ 중복된 아이디/이메일로 인해 가입 실패: " + username + " / " + email);
        } catch (SQLException e) {
            System.out.println("❌ SQL 오류 발생 (회원가입): " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ----------------------------------------------------------------
    // 2) 로그인 (username + password)
    //    - 이메일/인증여부를 dto.User에 함께 채워서 반환
    // ----------------------------------------------------------------
    public User login(String username, String password) {
        final String sql = "SELECT * FROM `user` WHERE `username`=? AND `password`=?";
        try (PreparedStatement pstmt = getConn().prepareStatement(sql)) {
            String hashedPassword = PasswordUtil.hashPassword(password);

            pstmt.setString(1, username);
            pstmt.setString(2, hashedPassword);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    User user = new User();
                    user.setId(rs.getInt("id"));
                    user.setUsername(rs.getString("username"));
                    user.setPassword(rs.getString("password")); // 해시
                    user.setName(rs.getString("name"));
                    try { user.setRole(rs.getString("role")); } catch (SQLException ignore) {}
                    try { user.setEmail(rs.getString("email")); } catch (SQLException ignore) {}
                    try { user.setEmailVerified(rs.getInt("email_verified")); } catch (SQLException ignore) {}
                    return user;
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ SQL 오류 발생 (로그인): " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ----------------------------------------------------------------
    // 3) 아이디 중복 확인
    // ----------------------------------------------------------------
    public boolean isAvailable(String username) {
        final String sql = "SELECT COUNT(*) FROM `user` WHERE `username`=?";
        try (PreparedStatement pstmt = getConn().prepareStatement(sql)) {
            pstmt.setString(1, username);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) == 0; // true = 사용 가능
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ SQL 오류 발생 (아이디 중복 확인): " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ----------------------------------------------------------------
    // 4) 이메일 중복 확인 (이메일 인증 가입 전 사전 체크용)
    // ----------------------------------------------------------------
    public boolean isEmailAvailable(String email) {
        final String sql = "SELECT COUNT(*) FROM `user` WHERE `email`=?";
        try (PreparedStatement pstmt = getConn().prepareStatement(sql)) {
            pstmt.setString(1, email);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) == 0; // true = 사용 가능
                }
            }
        } catch (SQLException e) {
            System.out.println("❌ SQL 오류 발생 (이메일 중복 확인): " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ----------------------------------------------------------------
    // 5) 편의: username/email 로 사용자 조회 (필요시 사용)
    // ----------------------------------------------------------------
    public User findByUsername(String username) {
        final String sql = "SELECT * FROM `user` WHERE `username`=?";
        try (PreparedStatement pstmt = getConn().prepareStatement(sql)) {
            pstmt.setString(1, username);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (Exception e) {
            System.out.println("❌ findByUsername 오류: " + e.getMessage());
        }
        return null;
    }

    public User findByEmail(String email) {
        final String sql = "SELECT * FROM `user` WHERE `email`=?";
        try (PreparedStatement pstmt = getConn().prepareStatement(sql)) {
            pstmt.setString(1, email);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (Exception e) {
            System.out.println("❌ findByEmail 오류: " + e.getMessage());
        }
        return null;
    }

    // ----------------------------------------------------------------
    // 내부 공통 매핑
    // ----------------------------------------------------------------
    private User mapRow(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setUsername(rs.getString("username"));
        user.setPassword(rs.getString("password")); // 해시된 값
        user.setName(rs.getString("name"));
        try { user.setRole(rs.getString("role")); } catch (SQLException ignore) {}
        try { user.setEmail(rs.getString("email")); } catch (SQLException ignore) {}
        try { user.setEmailVerified(rs.getInt("email_verified")); } catch (SQLException ignore) {}
        return user;
    }

    // ----------------------------------------------------------------
    // 6) 회원 정보 수정 (이름, 이메일, 비밀번호, 프로필 이미지)
    // ----------------------------------------------------------------
    public boolean updateUserProfile(User user, String newPassword) {
        StringBuilder sql = new StringBuilder(
            "UPDATE `user` SET `name`=?, `email`=?, `profile_image`=?"
        );

        // 새 비밀번호가 입력된 경우만 password 필드 포함
        boolean changePassword = (newPassword != null && !newPassword.trim().isEmpty());
        if (changePassword) {
            sql.append(", `password`=?");
        }
        sql.append(" WHERE `id`=?");

        try (PreparedStatement pstmt = getConn().prepareStatement(sql.toString())) {

            pstmt.setString(1, user.getName());
            pstmt.setString(2, user.getEmail());
            pstmt.setString(3, user.getProfileImage());

            int paramIndex = 4;

            if (changePassword) {
                String hashedPassword = PasswordUtil.hashPassword(newPassword);
                pstmt.setString(paramIndex++, hashedPassword);
            }

            pstmt.setInt(paramIndex, user.getId());

            int result = pstmt.executeUpdate();
            return result == 1;

        } catch (SQLException e) {
            System.out.println("❌ SQL 오류 (updateUserProfile): " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ----------------------------------------------------------------
    // 7) 리소스 정리: try-with-resources에서 자동 호출
    // ----------------------------------------------------------------
    @Override
    public void close() {
        if (conn != null) {
            try {
                if (!conn.isClosed()) conn.close();
            } catch (SQLException ignore) {}
        }
    }
}
