package util;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {
    public static Connection getConnection() throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = "jdbc:mysql://localhost:3306/grade_db"
                   + "?useUnicode=true&characterEncoding=utf8"
                   + "&serverTimezone=Asia/Seoul&useSSL=false&allowPublicKeyRetrieval=true";
        String user = "root";
        String pass = "8238";   // 본인 MySQL 비밀번호
        return DriverManager.getConnection(url, user, pass);
    }
}
