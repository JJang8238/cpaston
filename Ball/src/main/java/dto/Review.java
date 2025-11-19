package dto;

import java.sql.Timestamp;

public class Review {

    private int id;
    private String placeName;   // 풋살장 이름
    private String author;      // 작성자
    private int rating;         // 1~5
    private String content;     // 내용
    private Timestamp createdAt;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getPlaceName() { return placeName; }
    public void setPlaceName(String placeName) { this.placeName = placeName; }

    public String getAuthor() { return author; }
    public void setAuthor(String author) { this.author = author; }

    public int getRating() { return rating; }
    public void setRating(int rating) { this.rating = rating; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
