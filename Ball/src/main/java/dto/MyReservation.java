package dto;

public class MyReservation {
    private int reservationId;
    private int matchReservationId;
    private String location;
    private String matchDate; // yyyy-MM-dd
    private String matchTime; // HH:mm

    public int getReservationId() { return reservationId; }
    public void setReservationId(int reservationId) { this.reservationId = reservationId; }
    public int getMatchReservationId() { return matchReservationId; }
    public void setMatchReservationId(int matchReservationId) { this.matchReservationId = matchReservationId; }
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    public String getMatchDate() { return matchDate; }
    public void setMatchDate(String matchDate) { this.matchDate = matchDate; }
    public String getMatchTime() { return matchTime; }
    public void setMatchTime(String matchTime) { this.matchTime = matchTime; }
}
