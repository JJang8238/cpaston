package dto;

import java.time.LocalTime;

public class Match {
    private int id;
    private LocalTime matchTime;
    private String location;
    private int currentPlayers;
    private int maxPlayers;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public LocalTime getMatchTime() { return matchTime; }
    public void setMatchTime(LocalTime matchTime) { this.matchTime = matchTime; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public int getCurrentPlayers() { return currentPlayers; }
    public void setCurrentPlayers(int currentPlayers) { this.currentPlayers = currentPlayers; }

    public int getMaxPlayers() { return maxPlayers; }
    public void setMaxPlayers(int maxPlayers) { this.maxPlayers = maxPlayers; }
}
