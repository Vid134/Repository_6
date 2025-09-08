DROP DATABASE IF EXISTS IMDB;
CREATE DATABASE IMDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE IMDB;

-- Users who write reviews (and can be viewers)
CREATE TABLE users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(100) NOT NULL UNIQUE,
  email VARCHAR(255) UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Movies
CREATE TABLE movies (
  movie_id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  release_year YEAR,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Media items for a movie (can be image or video)
CREATE TABLE media (
  media_id INT AUTO_INCREMENT PRIMARY KEY,
  movie_id INT NOT NULL,
  media_type ENUM('image','video') NOT NULL,
  url VARCHAR(1000) NOT NULL,
  caption VARCHAR(500),
  added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Genres
CREATE TABLE genres (
  genre_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- Movie - Genre (many-to-many)
CREATE TABLE movie_genres (
  movie_id INT NOT NULL,
  genre_id INT NOT NULL,
  PRIMARY KEY (movie_id, genre_id),
  FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE,
  FOREIGN KEY (genre_id) REFERENCES genres(genre_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Reviews: each review belongs to a movie and a user
CREATE TABLE reviews (
  review_id INT AUTO_INCREMENT PRIMARY KEY,
  movie_id INT NOT NULL,
  user_id INT NOT NULL,
  rating TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 10),
  title VARCHAR(255),
  body TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Artists (actors, directors, crew)
CREATE TABLE artists (
  artist_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  birth_date DATE,
  bio TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Skills list (e.g., Singing, Stunt, Acting, Directing)
CREATE TABLE skills (
  skill_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- Artist-Skills many-to-many
CREATE TABLE artist_skills (
  artist_id INT NOT NULL,
  skill_id INT NOT NULL,
  PRIMARY KEY (artist_id, skill_id),
  FOREIGN KEY (artist_id) REFERENCES artists(artist_id) ON DELETE CASCADE,
  FOREIGN KEY (skill_id) REFERENCES skills(skill_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Roles (role types) e.g., "Lead Actor", "Supporting Actor", "Director"
CREATE TABLE role_types (
  role_type_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- Join table to let an artist play multiple roles in the same movie.
-- You can add character_name, billing_order, etc.
CREATE TABLE movie_artist_roles (
  movie_id INT NOT NULL,
  artist_id INT NOT NULL,
  role_type_id INT NOT NULL,
  character_name VARCHAR(255),
  credit_order INT,
  PRIMARY KEY (movie_id, artist_id, role_type_id,(character_name)),
  FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE,
  FOREIGN KEY (artist_id) REFERENCES artists(artist_id) ON DELETE CASCADE,
  FOREIGN KEY (role_type_id) REFERENCES role_types(role_type_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Indexes for faster lookups 
CREATE INDEX idx_movies_title ON movies(title);
CREATE INDEX idx_reviews_movie ON reviews(movie_id);
CREATE INDEX idx_media_movie ON media(movie_id);

-- Sample data 

INSERT INTO users (username, email) VALUES
('alice', 'alice@example.com'),
('bob', 'bob@example.com');

INSERT INTO movies (title, release_year, description) VALUES
('The Great Adventure', 2021, 'An epic journey.'),
('Space Mystery', 2022, 'Sci-fi thriller.');

INSERT INTO media (movie_id, media_type, url, caption) VALUES
(1, 'image', 'https://example.com/great_adventure/poster.jpg', 'Poster'),
(1, 'video', 'https://example.com/great_adventure/trailer.mp4', 'Trailer'),
(2, 'image', 'https://example.com/space_mystery/poster.jpg', 'Poster');

INSERT INTO genres (name) VALUES ('Action'), ('Adventure'), ('Sci-Fi'), ('Mystery');

-- link movies to multiple genres
INSERT INTO movie_genres (movie_id, genre_id) VALUES
(1, 1),(1,2),   -- The Great Adventure: Action, Adventure
(2, 3),(2,4);   -- Space Mystery: Sci-Fi, Mystery

-- Reviews following
INSERT INTO reviews (movie_id, user_id, rating, title, body)
VALUES
(1, 1, 9, 'Loved it', 'Great pacing and visuals'),
(1, 2, 8, 'Good', 'Entertaining family movie'),
(2, 2, 7, 'Intriguing', 'Nice concept but pacing issues');

-- Artists
INSERT INTO artists (name, birth_date) VALUES
('John Star', '1985-04-12'),
('Priya Kumar', '1990-09-01');

-- Skills
INSERT INTO skills (name) VALUES ('Acting'), ('Singing'), ('Stunts'), ('Directing');

--  Artist can have multiple skills or Artist skills
INSERT INTO artist_skills (artist_id, skill_id) VALUES
(1,1),(1,3),   -- John: Acting, Stunts
(2,1),(2,2);   -- Priya: Acting, Singing

--  types of roles
INSERT INTO role_types (name) VALUES ('Lead'), ('Supporting'), ('Director');

-- same artist can have multiple roles in same movie
INSERT INTO movie_artist_roles (movie_id, artist_id, role_type_id, character_name, credit_order) VALUES
(1,1,1,'Captain Blaze',1), -- John as Lead in The Great Adventure
(1,1,3,NULL,99),           -- John also credited as Director in same film
(1,2,2,'Rhea',2);          -- Priya as Supporting
