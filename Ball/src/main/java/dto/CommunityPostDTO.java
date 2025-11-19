package dto;

public class CommunityPostDTO {

    private int id;
    private String title;
    private String content;
    private String writer;
    private String regdate;   // ← 날짜 필드 추가

    // 기본 생성자
    public CommunityPostDTO() {}

    // getter / setter
    public int getId() {
        return id;
    }
    public void setId(int id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }
    public void setTitle(String title) {
        this.title = title;
    }

    public String getContent() {
        return content;
    }
    public void setContent(String content) {
        this.content = content;
    }

    public String getWriter() {
        return writer;
    }
    public void setWriter(String writer) {
        this.writer = writer;
    }

    public String getRegdate() {
        return regdate;
    }
    public void setRegdate(String regdate) {   // ← DAO에서 호출하려는 메서드
        this.regdate = regdate;
    }
}
