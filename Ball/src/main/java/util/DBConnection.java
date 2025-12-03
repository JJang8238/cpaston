package util;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {
    public static Connection getConnection() throws Exception {

        Class.forName("com.mysql.cj.jdbc.Driver");

        String url = "jdbc:mysql://database-1.cr6syquwsi52.ap-northeast-2.rds.amazonaws.com:3306/grade_db"
                   + "?useUnicode=true&characterEncoding=utf8"
                   + "&serverTimezone=Asia/Seoul&useSSL=true&allowPublicKeyRetrieval=true";

        String user = "admin";     // RDS에서 만든 master username
        String pass = "wkdtpguS9162";   // RDS master 비번

        return DriverManager.getConnection(url, user, pass);
    }
}
