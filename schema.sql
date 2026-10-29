PRAGMA foreign_keys = ON;

-- 요리 분류: 한식, 일식, 양식 등
CREATE TABLE cuisine (
    cuisine_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

-- 요리: 분류 번호로 cuisine과 연결
CREATE TABLE recipe (
    recipe_id INTEGER PRIMARY KEY,
    cuisine_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    cooking_minutes INTEGER NOT NULL CHECK (cooking_minutes > 0),
    FOREIGN KEY (cuisine_id) REFERENCES cuisine(cuisine_id)
);

-- 회원: 번호와 닉네임만 저장
CREATE TABLE member (
    member_id INTEGER PRIMARY KEY,
    nickname TEXT NOT NULL UNIQUE
);

-- 리뷰: 어떤 회원이 어떤 요리를 평가했는지 저장
CREATE TABLE review (
    review_id INTEGER PRIMARY KEY,
    recipe_id INTEGER NOT NULL,
    member_id INTEGER NOT NULL,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT NOT NULL,
    FOREIGN KEY (recipe_id) REFERENCES recipe(recipe_id),
    FOREIGN KEY (member_id) REFERENCES member(member_id)
);
