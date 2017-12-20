DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
  -- question_id INTEGER,
  --
  -- FOREIGN KEY (question_id) REFERENCES question(id)
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS questions_follows;

CREATE TABLE questions_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER,
  question_id INTEGER
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body TEXT NOT NULL,
  question_id INTEGER NOT NULL,
  reply_id INTEGER,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id)
  FOREIGN KEY (user_id) REFERENCES user(id)
  FOREIGN KEY (reply_id) REFERENCES reply(id)
);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
  FOREIGN KEY (question_id) REFERENCES questions(id)
);


INSERT INTO
  users (fname, lname)
VALUES
  ('Steven', 'Wang'),
  ('Eddie', 'Shin');

INSERT INTO
  questions (title, body, user_id)
VALUES
  ('What is SQL', 'What am I doing?', (SELECT id FROM users WHERE fname = 'Steven')),
  ('Where am I', 'Where the hell am I?', (SELECT id FROM users WHERE fname = 'Eddie'));

INSERT INTO
  replies (body, question_id, user_id, reply_id)
VALUES
  ('App Academy', (SELECT id FROM questions WHERE title = 'Where am I'),
  (SELECT id FROM users WHERE fname = 'Steven'), NULL);

INSERT INTO
  replies (body, question_id, user_id, reply_id)
VALUES
  ('I want to go home', (SELECT id FROM questions WHERE title = 'Where am I'),
  (SELECT id FROM users WHERE fname = 'Eddie'), (SELECT id FROM replies WHERE body = 'App Academy'));

INSERT INTO
  replies (body, question_id, user_id, reply_id)
VALUES
  ('You''re stuck here!', (SELECT id FROM questions WHERE title = 'Where am I'),
  (SELECT id FROM users WHERE fname = 'Steven'), (SELECT id FROM replies WHERE body = 'I want to go home'));

INSERT INTO
  questions_follows (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Steven'), NULL),
  ((SELECT id FROM users WHERE fname = 'Eddie'), NULL),
  (NULL, (SELECT id FROM questions WHERE title = 'What is SQL')),
  (NULL, (SELECT id FROM questions WHERE title = 'Where am I'));

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Steven'), (SELECT id FROM questions WHERE title = 'What is SQL')),
  ((SELECT id FROM users WHERE fname = 'Eddie'), (SELECT id FROM questions WHERE title = 'Where am I')),
  ((SELECT id FROM users WHERE fname = 'Steven'), (SELECT id FROM questions WHERE title = 'Where am I'));
