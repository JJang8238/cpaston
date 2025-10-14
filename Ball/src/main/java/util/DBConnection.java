package util;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {
    public static Connection getConnection() throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = "jdbc:mysql://localhost:3306/grade_DB?serverTimezone=UTC";  // ✅ DB 이름
        String user = "root";    // ✅ MySQL 사용자 이름
        String pass = "1234";    // ✅ MySQL 비밀번호
        return DriverManager.getConnection(url, user, pass);
    }
}
