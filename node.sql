CREATE TABLE lecturer (
    lecturer_id SERIAL PRIMARY KEY,
    email VARCHAR(50) NOT NULL,
    password VARCHAR(50),
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    lecturer_description VARCHAR(1000),
    image VARCHAR(50),
    type INT DEFAULT 0
);

CREATE TABLE lecture (
    lecture_id SERIAL PRIMARY KEY,
    lecturer_id INT NOT NULL,
    title VARCHAR(20) NOT NULL ,
    description VARCHAR(1000),
    image VARCHAR(50),
    creation_date DATE NOT NULL,
    ending_date DATE NOT NULL ,
    status BOOLEAN DEFAULT true,
    number_of_questions INT DEFAULT 0,
    CONSTRAINT fk_lecturer
                     FOREIGN KEY (lecturer_id)
                     REFERENCES lecturer(lecturer_id)
);

CREATE OR REPLACE FUNCTION update_status_on_lecture() RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT COUNT(*) FROM lecture WHERE ending_date < NOW() AND status = true) > 0 THEN
        UPDATE lecture SET status = false WHERE ending_date < NOW();
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_status_lecture
AFTER INSERT OR UPDATE OR DELETE ON lecture
FOR EACH ROW
EXECUTE FUNCTION update_status_on_lecture();

CREATE TABLE grades (
    lecture_id INT NOT NULL,
    grade INT NOT NULL,
    CONSTRAINT fk_lecture
                      FOREIGN KEY (lecture_id)
                      REFERENCES lecture(lecture_id)
);


CREATE TABLE question (
    question_id SERIAL PRIMARY KEY,
    lecture_id INT NOT NULL,
    text VARCHAR(500) NOT NULL,
    likes INT DEFAULT 0,
    answered BOOLEAN DEFAULT false,
    visible BOOLEAN DEFAULT true,
    CONSTRAINT fk_lecture
                      FOREIGN KEY (lecture_id)
                      REFERENCES lecture(lecture_id)
);


CREATE TABLE answer (
    answer_id SERIAL PRIMARY KEY,
    question_id INT,
    text VARCHAR(500),
    CONSTRAINT fk_question
                    FOREIGN KEY (question_id)
                    REFERENCES question(question_id)
);


--------------------------------------------------------
-- RESET
--
DELETE FROM answer;
DELETE FROM question;
DELETE FROM grades;
DELETE FROM lecture;
DELETE FROM lecturer;

ALTER SEQUENCE lecture_lecture_id_seq RESTART WITH 1000;
ALTER SEQUENCE answer_answer_id_seq RESTART WITH 1;
ALTER SEQUENCE question_question_id_seq RESTART WITH 1;
ALTER SEQUENCE lecturer_lecturer_id_seq RESTART WITH 1;
--------------------------------------------------------

-- USED TO MAKE ADMIN USERS
UPDATE lecturer SET type = 1 WHERE lecturer_id = 2;
