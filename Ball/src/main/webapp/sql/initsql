USE grade_db;
SELECT DATABASE();   -- grade_db 인지 확인

/* 1) 사용자(user) + 이메일 인증 테이블 */
CREATE TABLE `user` (
  id             INT AUTO_INCREMENT PRIMARY KEY,
  username       VARCHAR(50)  NOT NULL UNIQUE,
  password       VARCHAR(100) NOT NULL,
  name           VARCHAR(100) NOT NULL,
  role           VARCHAR(20)  NOT NULL DEFAULT 'student',
  email          VARCHAR(255) UNIQUE,
  email_verified TINYINT(1)   NOT NULL DEFAULT 0
);

CREATE TABLE email_verification (
  email       VARCHAR(255) NOT NULL PRIMARY KEY,
  code        VARCHAR(6)   NOT NULL,
  expires_at  DATETIME     NOT NULL,
  attempts    INT          NOT NULL DEFAULT 0
);

/* 2) 경기(match_reservations) */
CREATE TABLE match_reservations (
  id               INT AUTO_INCREMENT PRIMARY KEY,
  match_time       TIME         NOT NULL,
  match_date       DATE         NOT NULL,
  location         VARCHAR(100) NOT NULL,
  current_players  INT          NOT NULL DEFAULT 0,
  max_players      INT          NOT NULL DEFAULT 18,
  lat              DOUBLE       NULL,
  lng              DOUBLE       NULL,
  UNIQUE KEY ux_match_unique (location, match_date, match_time)
);

/* 3) 예약(reservations) */
CREATE TABLE reservations (
  id                     INT AUTO_INCREMENT PRIMARY KEY,
  user_id                INT NOT NULL,
  match_reservation_id   INT NOT NULL,
  created_at             TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_user_match (user_id, match_reservation_id),
  CONSTRAINT fk_resv_user
    FOREIGN KEY (user_id) REFERENCES `user`(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_resv_match
    FOREIGN KEY (match_reservation_id) REFERENCES match_reservations(id)
    ON UPDATE CASCADE ON DELETE CASCADE
);

USE grade_db;

-- 예약 기반 리뷰: 내가 뛴 경기용
CREATE TABLE IF NOT EXISTS match_reviews (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  match_reservation_id INT NOT NULL,
  rating TINYINT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES `user`(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (match_reservation_id) REFERENCES match_reservations(id) ON DELETE CASCADE ON UPDATE CASCADE,
  INDEX ix_mrv_user (user_id),
  INDEX ix_mrv_match (match_reservation_id)
);

-- 장소(마커) 기반 리뷰: 지도에서 “보기”에 사용 (쓰기 필요하면 나중에 추가)
CREATE TABLE IF NOT EXISTS place_reviews (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  place_name VARCHAR(100) NOT NULL,
  rating TINYINT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES `user`(id) ON DELETE CASCADE ON UPDATE CASCADE,
  INDEX ix_prv_place (place_name),
  INDEX ix_prv_user (user_id)
);

-- 데모용 --
INSERT INTO match_reservations (match_date, match_time, location, current_players, max_players)
VALUES (CURDATE(), '18:00:00', '증산체육공원', 4, 16);


