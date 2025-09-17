-- 0) 통째로 새로 시작
DROP DATABASE IF EXISTS grade_db;

-- 1) 생성 및 선택
CREATE DATABASE grade_db
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;
USE grade_db;

-- 2) user
CREATE TABLE user (
  id             INT AUTO_INCREMENT PRIMARY KEY,
  username       VARCHAR(50)  NOT NULL UNIQUE,
  password       VARCHAR(100) NOT NULL,
  name           VARCHAR(100) NOT NULL,
  role           VARCHAR(20)  NOT NULL DEFAULT 'student',
  email          VARCHAR(255) UNIQUE,              -- 이메일은 유니크
  email_verified TINYINT(1)   NOT NULL DEFAULT 0   -- 0=미인증, 1=인증
);

-- 3) 이메일 인증코드
CREATE TABLE email_verification (
  email       VARCHAR(255) NOT NULL PRIMARY KEY,
  code        VARCHAR(6)   NOT NULL,
  expires_at  DATETIME     NOT NULL,
  attempts    INT          NOT NULL DEFAULT 0
);

-- 4) 매치 테이블 (필요 시)
CREATE TABLE match_reservations (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  match_time      TIME         NOT NULL,
  location        VARCHAR(100) NOT NULL,
  current_players INT          NOT NULL DEFAULT 0,
  max_players     INT          NOT NULL DEFAULT 18
);

-- 5) 테스트 데이터(선택)
INSERT INTO match_reservations (match_time, location, current_players) VALUES
('10:00:00', '서울 풋살장', 14),
('12:00:00', '서울 풋살장', 10),
('14:00:00', '서울 풋살장', 15),
('16:00:00', '서울 풋살장', 18),
('18:00:00', '서울 풋살장', 8),
('20:00:00', '서울 풋살장', 12),
('22:00:00', '서울 풋살장', 17),
('23:59:00', '서울 풋살장', 13);

-- 6) 확인용
SHOW COLUMNS FROM user;
SHOW INDEX FROM user;


USE grade_db;

SELECT DATABASE();  -- grade_db 가 나와야 정상

SELECT COUNT(*) FROM user;

SELECT id, username, email
FROM user
WHERE username = '새아이디' OR email = '새이메일@예시.com';

--------------------------------------------------------------------

USE balldb;

DROP TABLE IF EXISTS email_verification;
DROP TABLE IF EXISTS user;

-- user 테이블
CREATE TABLE user (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(100) NOT NULL,
  name VARCHAR(100) NOT NULL,
  role VARCHAR(20) NOT NULL DEFAULT 'student',
  email VARCHAR(255) UNIQUE,
  email_verified TINYINT(1) NOT NULL DEFAULT 0
);

-- 이메일 인증 코드 저장 테이블
CREATE TABLE email_verification (
  email VARCHAR(255) NOT NULL PRIMARY KEY,
  code VARCHAR(6) NOT NULL,
  expires_at DATETIME NOT NULL,
  attempts INT NOT NULL DEFAULT 0
);

SHOW TABLES;
DESCRIBE user;
DESCRIBE email_verification;

SELECT * FROM user;
