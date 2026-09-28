-- ============================================================
-- PROYECTO: Historia de los Mundiales de Fútbol (Avance 1)
-- BASE DE DATOS: MySQL (Compatible con DB Fiddle)
-- ============================================================

DROP DATABASE IF EXISTS mundiales_db;
CREATE DATABASE mundiales_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE mundiales_db;

-- ------------------------------------------------------------
-- 1. TABLAS CATÁLOGO / INDEPENDIENTES
-- ------------------------------------------------------------

CREATE TABLE region (
    region_id INT AUTO_INCREMENT PRIMARY KEY,
    region_name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- `position` requiere comillas invertidas por ser palabra reservada en MySQL
CREATE TABLE `position` (
    position_id INT AUTO_INCREMENT PRIMARY KEY,
    position_name VARCHAR(50) NOT NULL UNIQUE,
    position_code VARCHAR(10)
) ENGINE=InnoDB;

CREATE TABLE award (
    award_id INT AUTO_INCREMENT PRIMARY KEY,
    award_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
) ENGINE=InnoDB;

CREATE TABLE confederation (
    confederation_id INT AUTO_INCREMENT PRIMARY KEY,
    confederation_name VARCHAR(100) NOT NULL UNIQUE,
    confederation_code VARCHAR(10) NOT NULL
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 2. TABLAS DE SEGUNDO NIVEL
-- ------------------------------------------------------------

CREATE TABLE country (
    country_id INT AUTO_INCREMENT PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL,
    country_code VARCHAR(10),
    region_id INT,
    CONSTRAINT fk_country_region 
        FOREIGN KEY (region_id) REFERENCES region(region_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE city (
    city_id INT AUTO_INCREMENT PRIMARY KEY,
    city_name VARCHAR(100) NOT NULL,
    country_id INT NOT NULL,
    CONSTRAINT fk_city_country 
        FOREIGN KEY (country_id) REFERENCES country(country_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE federation (
    federation_id INT AUTO_INCREMENT PRIMARY KEY,
    federation_name VARCHAR(150) NOT NULL,
    country_id INT,
    confederation_id INT,
    CONSTRAINT fk_federation_country 
        FOREIGN KEY (country_id) REFERENCES country(country_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_federation_confederation 
        FOREIGN KEY (confederation_id) REFERENCES confederation(confederation_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 3. TABLAS DE TERCER NIVEL
-- ------------------------------------------------------------

CREATE TABLE stadium (
    stadium_id INT AUTO_INCREMENT PRIMARY KEY,
    stadium_name VARCHAR(150) NOT NULL,
    capacity INT,
    city_id INT,
    CONSTRAINT fk_stadium_city 
        FOREIGN KEY (city_id) REFERENCES city(city_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE tournament (
    tournament_id INT AUTO_INCREMENT PRIMARY KEY,
    tournament_name VARCHAR(100) NOT NULL,
    year INT NOT NULL,
    host_country_id INT,
    start_date DATE,
    end_date DATE,
    CONSTRAINT fk_tournament_host 
        FOREIGN KEY (host_country_id) REFERENCES country(country_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE player (
    player_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    given_name VARCHAR(150),
    family_name VARCHAR(150),
    birth_date DATE,
    country_id INT,
    position_id INT,
    CONSTRAINT fk_player_country 
        FOREIGN KEY (country_id) REFERENCES country(country_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_player_position 
        FOREIGN KEY (position_id) REFERENCES `position`(position_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE team (
    team_id INT AUTO_INCREMENT PRIMARY KEY,
    team_name VARCHAR(100) NOT NULL,
    country_id INT,
    federation_id INT,
    CONSTRAINT fk_team_country 
        FOREIGN KEY (country_id) REFERENCES country(country_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_team_federation 
        FOREIGN KEY (federation_id) REFERENCES federation(federation_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 4. TABLAS DE EVENTOS Y DETALLES
-- ------------------------------------------------------------

CREATE TABLE matches (
    match_id INT AUTO_INCREMENT PRIMARY KEY,
    tournament_id INT NOT NULL,
    stadium_id INT,
    match_date DATE,
    stage_name VARCHAR(100),
    home_team_id INT NOT NULL,
    away_team_id INT NOT NULL,
    home_score INT DEFAULT 0,
    away_score INT DEFAULT 0,
    outcome VARCHAR(50),
    CONSTRAINT fk_matches_tournament 
        FOREIGN KEY (tournament_id) REFERENCES tournament(tournament_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_matches_stadium 
        FOREIGN KEY (stadium_id) REFERENCES stadium(stadium_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_matches_home_team 
        FOREIGN KEY (home_team_id) REFERENCES team(team_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_matches_away_team 
        FOREIGN KEY (away_team_id) REFERENCES team(team_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE award_winner (
    award_winner_id INT AUTO_INCREMENT PRIMARY KEY,
    award_id INT NOT NULL,
    tournament_id INT NOT NULL,
    player_id INT,
    team_id INT,
    CONSTRAINT fk_award_winner_award 
        FOREIGN KEY (award_id) REFERENCES award(award_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_award_winner_tournament 
        FOREIGN KEY (tournament_id) REFERENCES tournament(tournament_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_award_winner_player 
        FOREIGN KEY (player_id) REFERENCES player(player_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_award_winner_team 
        FOREIGN KEY (team_id) REFERENCES team(team_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE player_appearance (
    appearance_id INT AUTO_INCREMENT PRIMARY KEY,
    match_id INT NOT NULL,
    player_id INT NOT NULL,
    team_id INT NOT NULL,
    position_id INT,
    starter BOOLEAN DEFAULT TRUE,
    shirt_number INT,
    CONSTRAINT fk_appearance_match 
        FOREIGN KEY (match_id) REFERENCES matches(match_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_appearance_player 
        FOREIGN KEY (player_id) REFERENCES player(player_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_appearance_team 
        FOREIGN KEY (team_id) REFERENCES team(team_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_appearance_position 
        FOREIGN KEY (position_id) REFERENCES `position`(position_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE goal (
    goal_id INT AUTO_INCREMENT PRIMARY KEY,
    match_id INT NOT NULL,
    player_id INT NOT NULL,
    team_id INT NOT NULL,
    minute INT,
    own_goal BOOLEAN DEFAULT FALSE,
    penalty BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_goal_match 
        FOREIGN KEY (match_id) REFERENCES matches(match_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_goal_player 
        FOREIGN KEY (player_id) REFERENCES player(player_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_goal_team 
        FOREIGN KEY (team_id) REFERENCES team(team_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
