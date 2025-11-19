package dto;

import java.time.LocalDate;
import java.time.LocalTime;

public class Match {

    private int id;
    private LocalDate matchDate;   // ⭐ 추가됨
    private LocalTime matchTime;
    private String location;
    private int currentPlayers;
    private int maxPlayers;
    private String matchStatus;    // 예약중 / 취소됨 / 완료

    // -------------------------
    // 기본 생성자
    // -------------------------
    public Match() {}

    // -------------------------
    // Getter / Setter
    // -------------------------

    public int getId() { 
        return id; 
    }
    public void setId(int id) { 
        this.id = id; 
    }

    public LocalDate getMatchDate() { 
        return matchDate; 
    }
    public void setMatchDate(LocalDate matchDate) { 
        this.matchDate = matchDate; 
    }

    public LocalTime getMatchTime() { 
        return matchTime; 
    }
    public void setMatchTime(LocalTime matchTime) { 
        this.matchTime = matchTime; 
    }

    public String getLocation() { 
        return location; 
    }
    public void setLocation(String location) { 
        this.location = location; 
    }

    public int getCurrentPlayers() { 
        return currentPlayers; 
    }
    public void setCurrentPlayers(int currentPlayers) { 
        this.currentPlayers = currentPlayers; 
    }

    public int getMaxPlayers() { 
        return maxPlayers; 
    }
    public void setMaxPlayers(int maxPlayers) { 
        this.maxPlayers = maxPlayers; 
    }

    public String getMatchStatus() { 
        return matchStatus; 
    }
    public void setMatchStatus(String matchStatus) { 
        this.matchStatus = matchStatus; 
    }
}
