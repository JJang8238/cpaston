package util;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.nio.charset.StandardCharsets;
import java.util.Properties;

public class EmailUtil {

    // ✅ 네이버 SMTP 계정 설정
    private static final String SMTP_HOST = "smtp.naver.com";
    private static final int    SMTP_PORT = 465;   // SSL 포트
    private static final String USERNAME  = "jjang761213@naver.com"; // 네이버 이메일 주소 전체
    private static final String PASSWORD  = "E1BDZDR62ULM";   // 네이버에서 발급받은 앱 비밀번호
    private static final String SENDER_NAME = "플랩풋볼"; // 메일 발신자 이름

    private static Session session() {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.ssl.enable", "true");   // SSL 사용
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", String.valueOf(SMTP_PORT));
        props.put("mail.smtp.ssl.trust", SMTP_HOST);
        // 필요시 디버그 출력
        // props.put("mail.debug", "true");

        return Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(USERNAME, PASSWORD);
            }
        });
    }

    /** 일반 텍스트 메일 발송 */
    public static void sendText(String to, String subject, String text) throws Exception {
        Session s = session();

        MimeMessage message = new MimeMessage(s);
        message.setFrom(new InternetAddress(
                USERNAME,           // 반드시 로그인한 네이버 주소와 같아야 함
                SENDER_NAME,
                StandardCharsets.UTF_8.name()
        ));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
        message.setSubject(subject, StandardCharsets.UTF_8.name());
        message.setText(text, StandardCharsets.UTF_8.name());

        Transport.send(message);
    }
}
