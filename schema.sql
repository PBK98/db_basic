-- SQLite용 스키마. 새 DB에서 한 번 실행하세요.
-- SQLite는 연결할 때마다 외래 키 검사를 켜야 합니다.
PRAGMA foreign_keys = ON;

-- 요리 분류 한 개에는 여러 요리를 등록할 수 있습니다.
CREATE TABLE cuisine (
    cuisine_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT NOT NULL
);

CREATE TABLE recipe (
    recipe_id INTEGER PRIMARY KEY,
    cuisine_id INTEGER NOT NULL,
    name TEXT NOT NULL UNIQUE,
    main_ingredient TEXT NOT NULL,
    cooking_minutes INTEGER NOT NULL CHECK (cooking_minutes > 0),
    difficulty TEXT NOT NULL CHECK (difficulty IN ('쉬움', '보통', '어려움')),
    FOREIGN KEY (cuisine_id) REFERENCES cuisine(cuisine_id)
);

CREATE TABLE member (
    member_id INTEGER PRIMARY KEY,
    nickname TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE
);

-- 날짜는 SQLite에서 YYYY-MM-DD 형식의 TEXT로 저장합니다.
CREATE TABLE review (
    review_id INTEGER PRIMARY KEY,
    recipe_id INTEGER NOT NULL,
    member_id INTEGER NOT NULL,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT NOT NULL,
    created_at TEXT NOT NULL,
    UNIQUE (recipe_id, member_id),
    FOREIGN KEY (recipe_id) REFERENCES recipe(recipe_id),
    FOREIGN KEY (member_id) REFERENCES member(member_id)
);
