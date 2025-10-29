package dto;

import java.io.Serializable;

public class User implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;               // 기본키
    private String username;      // 아이디
    private String password;      // 비밀번호 (DB에는 해시 저장)
    private String name;          // 이름
    private String role = "student"; // 기본 권한
    private String email;         // 이메일
    private int emailVerified;    // 0 = 미인증, 1 = 인증완료
    private String profileImage;
    
    public User() {}

    public User(int id, String username, String password, String name,
                String role, String email, int emailVerified) {
        this.id = id;
        this.username = username;
        this.password = password;
        this.name = name;
        this.role = role;
        this.email = email;
        this.emailVerified = emailVerified;
    }

    // --- Getter & Setter ---
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    /** 주의: password는 해시된 값으로 저장/세팅 */
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public int getEmailVerified() { return emailVerified; }
    public void setEmailVerified(int emailVerified) { this.emailVerified = emailVerified; }
    
    public String getProfileImage() { return profileImage; }
    public void setProfileImage(String profileImage) { this.profileImage = profileImage; }

    // --- 편의 메서드 ---
    /** 인증 여부를 boolean 으로 바로 확인 */
    public boolean isEmailVerified() { return emailVerified == 1; }

    /** 인증 완료로 마킹 */
    public void markEmailVerified() { this.emailVerified = 1; }

    /** 디버깅/로그용 toString */
    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", username='" + username + '\'' +
                ", name='" + name + '\'' +
                ", role='" + role + '\'' +
                ", email='" + email + '\'' +
                ", emailVerified=" + emailVerified +
                '}';
    }
}
