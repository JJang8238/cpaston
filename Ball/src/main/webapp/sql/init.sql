USE grade_db;
SELECT DATABASE();   -- grade_db 인지 확인

/* 1) 사용자(user) + 이메일 인증 테이블 */
CREATE TABLE `user` (
  id             INT AUTO_INCREMENT PRIMARY KEY,
  username       VARCHAR(50)  NOT NULL UNIQUE,
  password       VARCHAR(100) NOT NULL,
  name           VARCHAR(100) NOT NULL,
  role           VARCHAR(20)  NOT NULL DEFAULT 'users',
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

CREATE TABLE IF NOT EXISTS post (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  title        VARCHAR(200)  NOT NULL,
  content      MEDIUMTEXT    NOT NULL,
  category     ENUM('전체','인기글','동네질문') NOT NULL DEFAULT '전체',
  author       VARCHAR(100)  NOT NULL,             -- 작성자 표시용(세션의 username)
  created_at   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   TIMESTAMP     NULL ON UPDATE CURRENT_TIMESTAMP
);

/* ============================================================
 7) 게시판(board)
============================================================ */
CREATE TABLE board (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) UNIQUE NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO board (name, sort_order) VALUES
('전체', 1),
('인기글', 2),
('동네질문', 3);

SELECT * FROM board ORDER BY sort_order
/* ============================================================
 8) 게시글(post)
============================================================ */
CREATE TABLE post (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  content MEDIUMTEXT NOT NULL,
  author VARCHAR(100) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,

  likes INT DEFAULT 0,
  dislikes INT DEFAULT 0,
  reports INT DEFAULT 0,

  board_id INT NOT NULL DEFAULT 1,
  FOREIGN KEY (board_id) REFERENCES board(id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

/* ============================================================
 9) 게시글 투표(post_vote_log)
============================================================ */
CREATE TABLE post_vote_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    vote_type ENUM('like','dislike') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY uk_vote_unique (post_id, user_id),

    FOREIGN KEY (post_id) REFERENCES post(id)
        ON DELETE CASCADE,

    FOREIGN KEY (user_id) REFERENCES user(id)
        ON DELETE CASCADE
);

/* ============================================================
 10) 게시글 신고(post_report_log)
============================================================ */
CREATE TABLE post_report_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY uk_report_unique (post_id, user_id),

    FOREIGN KEY (post_id) REFERENCES post(id)
        ON DELETE CASCADE
);

INSERT INTO user (username, password, name, email, email_verified, role, profile_image)
VALUES (
    'test6',                                                   -- 아이디
    SHA2('1234', 256),                                          -- 비밀번호(평문 X)
    '김요우',                                                    -- 이름
    'lejㄴsh1012@gmail.com',                                         -- 이메일
    1,                                                          -- 이메일 인증됨(1) 처리
    'student',                                                  -- 권한
    'default-profile.png'                                       -- 기본 이미지
);

INSERT INTO match_reservations (match_date, match_time, location, current_players, max_players, match_status)
VALUES 
('2025-12-10', '10:00:00', '양주시유소년축구클럽', 2, 18, '예약중'),
('2025-12-10', '12:00:00', '양주시유소년축구클럽', 5, 18, '예약중'),
('2025-12-10', '14:00:00', '양주시유소년축구클럽', 7, 18, '예약중'),
('2025-12-10', '16:00:00', '양주시유소년축구클럽', 9, 18, '예약중'),
('2025-12-10', '18:00:00', '양주시유소년축구클럽', 1, 18, '예약중'),
('2025-12-10', '20:00:00', '양주시유소년축구클럽', 0, 18, '예약중'),
('2025-12-10', '22:00:00', '양주시유소년축구클럽', 2, 18, '예약중');

UPDATE user 
SET role = 'user'
WHERE role = 'student';

ALTER TABLE user 
MODIFY role VARCHAR(20) NOT NULL DEFAULT 'user';
