-- Спроектирвоать базу для хранения фильмов
-- База должна давать возможность хранить информацию как на странице:
-- https://www.kinopoisk.ru/film/435/

-- - Для хранения художников, композиторов, монтажеров и пр используем одну таблицу person
-- -- упрощаем и чтобы не плодить кучу таблиц только в главных ролях и роли дублировали будут иметь (film-person) связь многие ко многим
-- -- для остальных ставим связь один ко многим (поэтому в графе сценарий у нас для фильма будет всего один сценарист [например, только Фрэнк Дарабонт], аналогично и по другим полям персон)
-- - Жанры также хранятся в отдельной таблице исвязываются далее с фильмами
-- - зрители по странам тоже в отдельной таблице (флажки можно не хранить)
-- ВСЕ ПРО ЧТО В ПРОЕКТИРОВНИИ МНОЮ ЯВНО НЕ СКАЗАНО МОЖНО ДЕЛАТЬ НА СВОЕ УСМОТРЕНИЕ
-- В качестве результата загрузить SQL код на github, который генерирует соответсвующую структуру БД

DROP TABLE IF EXISTS distribution;
DROP TABLE IF EXISTS distributor;
DROP TABLE IF EXISTS audiotrack;
DROP TABLE IF EXISTS subtitles;
DROP TABLE IF EXISTS film_genre;
DROP TABLE IF EXISTS film_person;
DROP TABLE IF EXISTS genre;
DROP TABLE IF EXISTS audience;
DROP TABLE IF EXISTS person CASCADE;
DROP TABLE IF EXISTS review;
DROP TABLE IF EXISTS reviewer;
DROP TABLE IF EXISTS film;
DROP TABLE IF EXISTS MPAA;
DROP TABLE IF EXISTS country;
DROP TABLE IF EXISTS language;



CREATE TABLE country (
    id SERIAL PRIMARY KEY,
    name VARCHAR(256) NOT NULL,
    flag VARCHAR(20)
);

CREATE TABLE MPAA (
    id SERIAL PRIMARY KEY,
    letter VARCHAR(1),
    description TEXT
);

-- актеры и команда 
CREATE TABLE person (
    id SERIAL PRIMARY KEY,
    forename VARCHAR(50),
    surname VARCHAR(50)
);

CREATE TABLE film (
    id SERIAL PRIMARY KEY,
    title VARCHAR(256) NOT NULL,
    original_title VARCHAR(256) NOT NULL,
    release_year INTEGER,
    producing_country INTEGER REFERENCES country(id),
    slogan VARCHAR(512),
    desription VARCHAR(2048),

    -- who made&
    regiser INTEGER REFERENCES person(id),
    scenarist INTEGER REFERENCES person(id),
    producer INTEGER REFERENCES person(id),
    operator INTEGER REFERENCES person(id),
    compositor INTEGER REFERENCES person(id),
    designer INTEGER REFERENCES person(id),  -- художник
    editor INTEGER REFERENCES person(id),    -- монтаж

    -- что по деньгам?
    budget Integer,
    marketing Integer,
    fees_usa Integer,
    fees_world Integer,

    -- информация о дистрибюторе и дате появления в стране / мире - в таблице distribution

    min_age Integer,
    duration Time,
    MPAA_rating INTEGER REFERENCES MPAA(id)
);

CREATE TABLE distributor (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50)
);

CREATE TABLE distribution (
    distributor_id INTEGER REFERENCES distributor(id),
    film_id INTEGER REFERENCES film(id),
    country_id INTEGER REFERENCES country(id), 
    release Date,
    CONSTRAINT one_film_distributor_per_country PRIMARY KEY (distributor_id, film_id, country_id)
);

CREATE TABLE language (
    id SERIAL PRIMARY KEY,
    name VARCHAR(256)
);

CREATE TABLE audiotrack (
    id SERIAL PRIMARY KEY,
    film_id  INTEGER REFERENCES film(id),
    language_id  INTEGER REFERENCES language(id)
);

CREATE TABLE subtitles (
    film_id  INTEGER REFERENCES film(id),
    language_id  INTEGER REFERENCES language(id),
    CONSTRAINT unique_film_subtitles_pair PRIMARY KEY (film_id, language_id)
);

CREATE TABLE genre (
    id SERIAL PRIMARY KEY,
    name VARCHAR(256)
);

CREATE TABLE film_genre (
    film_id  INTEGER REFERENCES film(id),
    genre_id INTEGER REFERENCES genre(id),
    CONSTRAINT unique_film_genre_pairs PRIMARY KEY (film_id, genre_id)
);

-- сколько народу смотрело
CREATE TABLE audience (
    country_id INTEGER REFERENCES country(id),
    film_id INTEGER REFERENCES film(id),
    views Integer,

    -- одна старан - 1 количествоо просмотров (для 1 фильма)
    CONSTRAINT unique_country_film_views_count PRIMARY KEY (film_id, country_id)

);

CREATE TABLE film_person (
    id SERIAL PRIMARY KEY,
    film_id   INTEGER REFERENCES film(id),
    person_id INTEGER REFERENCES person(id), 
    main_role BOOLEAN
);

CREATE TABLE reviewer (
    id SERIAL PRIMARY KEY,
    nickname VARCHAR(50),
    avatar VARCHAR(50) --- ссылка на картинку

    -- остальные поля опускаю, т.к. к фильму относятся 
    -- только оставленные пользователем рецензии  
);

CREATE TABLE review (
    film_id INTEGER REFERENCES film(id) ON DELETE CASCADE,
    reviewer_id INTEGER REFERENCES reviewer(id) ON DELETE CASCADE,
    message TEXt,
    submited_on TIMESTAMP DEFAULT NOW(),
    Liked_by INTEGER REFERENCES reviewer(id) ON DELETE CASCADE,
    disLiked_by INTEGER REFERENCES reviewer(id) ON DELETE CASCADE,


    -- reviewer can review many films, but each film - only once
    CONSTRAINT unique_film_reviewer_pair PRIMARY KEY (film_id, reviewer_id)
);



INSERT INTO person (id, forename, surname)
VALUES 
    -- film crew 
    (1, 'Фрэнк', 'Дарабонт'),
    (2, 'Стивен',  'Кинг'),
    (3, 'Дэвидэ', 'Тэттерсолл'),
    (4, 'Томас', 'Ньюман'),
    (5, 'Теренс',  'Марш'),
    (6, 'Ричард',  'Фрэнсис-Брюс'),

    -- main roles
    (7, 'Том',  'Хэнкс'),
    (8, 'Дэвид', 'Морс'),
    (9, 'Бонни', 'Хант'),
    (10, 'Майкл', 'Кларк Дункан'),
    (11, 'Джеймс', 'Кромуэлл'),
    (12, 'Майкл', 'Джитер'),
    (13, 'Грэм', 'Грин'),
    (14, 'Даг', 'Хатчисон'),
    (15, 'Сэм', 'Рокуэлл'),
    (16, 'Барри', 'Пеппер'),

    -- dublers
    (17, 'Всеволод', 'Кузнецов'),
    (18, 'Владимир', 'Антоник'),
    (19, 'Любовь',  'Германова'),
    (20, 'Валентин', 'Голубенко'),
    (21, 'Александр', 'Белявский')
;

INSERT INTO country(id, name, flag)
VALUES
    (1, 'USA', 'U+1F1FA U+1F1F8'),
    (2, 'Germany', 'U+1F1E9 U+1F1EA')
;

INSERT INTO film
(
    id,
    title,
    original_title,
    release_year,
    producing_country,
    slogan,
    desription,
    -- crew
    regiser,
    scenarist,
    producer,
    operator,
    compositor,
    designer,
    editor,
    budget,
    marketing,
    fees_usa,
    fees_world

)
VALUES 
(
    1,
    'Зеленая миля',    -- title
    'The Green Mile',  -- original_title
    1999,              -- release_year
    1,                 -- producing_country (USA)
    'Пол Эджкомб не верил в чудеса. Пока не столкнулся с одним из них', -- slogan
    'В тюрьме для смертников...',                                       -- desription
    1,   -- regiser     Фрэнк Дарабонт
    2,   -- scenarist   Стивен Кинг
    1,   -- producer    Фрэнк Дарабонт
    3,   -- operator    Дэвид Тэттерсолл
    4,   -- compositor  Томас Ньюман
    5,   -- designer    Теренс Марш
    6,   -- editor      Ричард Фрэнсис-Брюс
    60000000,    -- buget
    30000000,    -- marketing
    136801374,   -- fees_usa
    286801374    -- fees_worls
);

INSERT INTO genre (id, name) 
VALUES
    (1, 'драма'),
    (2, 'фэнтези'),
    (3, 'криминал')
;

INSERT INTO film_genre (film_id, genre_id)
VALUES
    (1, 1),
    (1, 2),
    (1, 3)
;

INSERT INTO audience (country_id, film_id, views)
VALUES 
    (1, 1, 26000000),
    (2, 1, 2100000)
;

INSERT INTO film_person (film_id, person_id, main_role)
VALUES
    -- main roles
    (1, 7, true),
    (1, 8, true),
    (1, 9, true),
    (1, 10, true),
    (1, 11, true),
    (1, 12, true),
    (1, 13, true),
    (1, 14, true),
    (1, 15, true),
    (1, 16, true),
    -- dublers
    (1, 17, false),
    (1, 18, false),
    (1, 19, false),
    (1, 20, false),
    (1, 21, false)
;


INSERT INTO reviewer (id, nickname)
VALUES
    (1, 'Vasa Pupkin')
;

INSERT INTO review (film_id, reviewer_id, message)
VALUES
    (1, 1, 'Не. ну мой взгляд могли бы и...')
;
