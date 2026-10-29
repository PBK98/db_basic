PRAGMA foreign_keys = ON;

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
