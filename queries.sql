-- SQLite에서 실행합니다. Q01~Q15가 과제의 핵심 쿼리입니다.
-- Q13, Q14의 BEGIN/SELECT/ROLLBACK은 변경 확인 및 복구용입니다.
PRAGMA foreign_keys = ON;

-- Q01 | 기본 조회: 모든 요리의 이름과 조리 시간을 확인합니다.
SELECT recipe_id, name, cooking_minutes FROM recipe ORDER BY recipe_id;

-- Q02 | 기본 조회: 20분 이내에 만들 수 있는 요리를 찾습니다.
SELECT name, cooking_minutes FROM recipe
WHERE cooking_minutes <= 20 ORDER BY cooking_minutes, recipe_id;

-- Q03 | 기본 조회: 20분 이내 요리 중 조리 시간이 짧은 5개를 찾습니다.
-- LIMIT는 SQLite에서 지원하는 행 수 제한 문법입니다.
SELECT name, cooking_minutes FROM recipe
WHERE cooking_minutes <= 20 ORDER BY cooking_minutes, recipe_id LIMIT 5;

-- Q04 | 기본 조회: 이름에 파스타가 들어간 요리를 검색합니다.
SELECT name, cooking_minutes FROM recipe
WHERE name LIKE '%파스타%' ORDER BY recipe_id;

-- Q05 | INNER JOIN: 요리 이름 옆에 분류 이름을 표시합니다.
SELECT r.name AS recipe_name, c.name AS cuisine_name
FROM recipe AS r INNER JOIN cuisine AS c ON r.cuisine_id = c.cuisine_id
ORDER BY r.recipe_id;

-- Q06 | INNER JOIN: 리뷰에 작성자 닉네임과 요리 이름을 붙입니다.
SELECT v.review_id, m.nickname, r.name, v.rating, v.comment
FROM review AS v
INNER JOIN member AS m ON v.member_id = m.member_id
INNER JOIN recipe AS r ON v.recipe_id = r.recipe_id
ORDER BY v.review_id;

-- Q07 | LEFT JOIN: 리뷰가 없는 요리도 목록에 남깁니다.
SELECT r.name, v.rating, v.comment
FROM recipe AS r LEFT JOIN review AS v ON r.recipe_id = v.recipe_id
ORDER BY r.recipe_id, v.review_id;

-- Q08 | LEFT JOIN: 리뷰를 한 번도 쓰지 않은 회원을 찾습니다.
SELECT m.member_id, m.nickname
FROM member AS m LEFT JOIN review AS v ON m.member_id = v.member_id
WHERE v.review_id IS NULL ORDER BY m.member_id;

-- Q09 | 집계: 분류별 요리 개수를 셉니다.
SELECT c.name, COUNT(r.recipe_id) AS recipe_count
FROM cuisine AS c LEFT JOIN recipe AS r ON c.cuisine_id = r.cuisine_id
GROUP BY c.cuisine_id, c.name ORDER BY c.cuisine_id;

-- Q10 | 집계: 요리별 리뷰 수와 평균 평점을 구합니다.
SELECT r.name, COUNT(v.review_id) AS review_count,
       ROUND(AVG(v.rating), 2) AS average_rating
FROM recipe AS r LEFT JOIN review AS v ON r.recipe_id = v.recipe_id
GROUP BY r.recipe_id, r.name
ORDER BY average_rating DESC, r.recipe_id;

-- Q11 | 집계: 분류별 평균 조리 시간과 조리 시간 합계를 구합니다.
SELECT c.name, ROUND(AVG(r.cooking_minutes), 2) AS average_minutes,
       SUM(r.cooking_minutes) AS total_minutes
FROM cuisine AS c INNER JOIN recipe AS r ON c.cuisine_id = r.cuisine_id
GROUP BY c.cuisine_id, c.name ORDER BY c.cuisine_id;

-- Q12 | 서브쿼리: 전체 평균보다 조리 시간이 긴 요리를 찾습니다.
SELECT name, cooking_minutes FROM recipe
WHERE cooking_minutes > (SELECT AVG(cooking_minutes) FROM recipe)
ORDER BY cooking_minutes DESC, recipe_id;

-- Q13 | UPDATE: 김치볶음밥의 조리 시간을 15분에서 18분으로 바꿉니다.
BEGIN TRANSACTION;
UPDATE recipe SET cooking_minutes = 18 WHERE recipe_id = 1;
SELECT recipe_id, name, cooking_minutes FROM recipe WHERE recipe_id = 1;
ROLLBACK;

-- Q14 | DELETE: 20번 리뷰를 삭제하고 남은 리뷰 개수를 확인합니다.
BEGIN TRANSACTION;
DELETE FROM review WHERE review_id = 20;
SELECT COUNT(*) AS remaining_reviews FROM review;
SELECT COUNT(*) AS deleted_review_count FROM review WHERE review_id = 20;
ROLLBACK;

-- Q15 | 인덱스: 특정 회원의 리뷰를 찾거나 조인할 때 검색을 돕습니다.
-- 회원별 리뷰 조회에 사용하는 member_id에 인덱스를 만듭니다.
CREATE INDEX IF NOT EXISTS idx_review_member_id ON review(member_id);
-- SQLite 전용: 인덱스가 실제 검색 계획에 나타나는지 확인합니다.
EXPLAIN QUERY PLAN SELECT * FROM review WHERE member_id = 1;
