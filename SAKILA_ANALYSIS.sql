USE sakila;
-- actor, film, customer, staff, rental, inventory
DESC actor;
DESC film;
DESC customer;
DESC staff;
DESC rental;
DESC inventory;

-- 배우 이름을 합쳐서 '배우' 조회
SELECT CONCAT_WS(' ',first_name, last_name) '배우' FROM actor;

SELECT UPPER(CONCAT(first_name,' ',last_name)) FROM actor;

-- son으로 끝나는 성을 가진 배우
SELECT CONCAT_WS(' ',first_name, last_name) '배우'
	FROM actor
    WHERE last_name LIKE '%son';
    
-- 배우들이 출연한 영화
SELECT CONCAT_WS(' ',A.first_name, A.last_name) '배우', F.title '영화 제목', F.release_year '개봉연도'
	FROM actor A, film_actor FA, film F
    WHERE A.actor_id=FA.actor_id
    AND FA.film_id=F.film_id;
    
-- 성(last name)에 따른 배우 수
SELECT last_name '성', COUNT(last_name) '해당 성을 가진 배우 수'
	FROM actor 
    GROUP BY last_name
    ORDER BY COUNT(last_name) DESC, last_name;
    
-- country가 오스트레일리아, 독일
DESC country;
SELECT country_id, country
FROM country
WHERE country IN ('AUSTRALIA','GERMANY');

-- 스탭 테이블에서 성과 이름을 합치기 + staff 테이블과 adress 테이블 합치고 adrress, district, postal_code, city_id 조회
SELECT CONCAT_WS(' ',ST.first_name, ST.last_name) '스탭',
	   ADR.address, ADR.district, ADR.postal_code, ADR.city_id
       FROM staff ST
       LEFT JOIN address ADR 
       ON ST.address_id=ADR.address_id;
       
-- 스탭 성과 이름 합치고 payment 테이블과 합치기 + 7월 이면서 2005년 데이터를 스탭 이름 기준으로 조회
SELECT CONCAT_WS(' ',ST.first_name, ST.last_name) '스탭',
       SUM(P.amount) '2005년 7월 월급'
	FROM staff ST
	LEFT JOIN payment P
    ON P.staff_id=ST.staff_id
    WHERE MONTH(P.payment_date)=7
    AND YEAR(P.payment_date)=2005
    GROUP BY ST.first_name, ST.last_name;

-- 영화별 출연 배우의 수
SELECT F.title '영화 제목', COUNT(A.actor_id) '출연 배우 수'
	FROM film F, actor A, film_actor FA
    WHERE A.actor_id=FA.actor_id
    AND FA.film_id=F.film_id
    GROUP BY F.title
    ORDER BY COUNT(A.actor_id) DESC;
    
-- '영화이름' 넣으면 출연 배우들 추출
SELECT CONCAT_WS(' ',first_name, last_name) '출연 배우'
	FROM actor
    WHERE actor_id IN (SELECT actor_id FROM film_actor
	WHERE film_id IN (SELECT film_id FROM film 
    WHERE LOWER(title)=LOWER('HALLOWEEN NUTS')));

-- 국가가 CANADA인 고객의 이름 서브쿼리 이용하여 추출
SELECT CONCAT(first_name, ' ', last_name) 고객, email
	FROM customer
    WHERE address_id IN (SELECT address_id FROM address
    WHERE city_id IN (SELECT city_id FROM city
    WHERE country_id IN (SELECT country_id FROM country
    WHERE country='CANADA')));
    
SELECT CONCAT(CUS.first_name, ' ', CUS.last_name) 고객, CUS.email
	FROM customer CUS
    JOIN address ADR ON CUS.address_id=ADR.address_id
    JOIN city CIT ON ADR.city_id=CIT.city_id
    JOIN country COU ON CIT.country_id=COU.country_id
    WHERE COU.country='CANADA';
    
-- 영화 등급
SELECT rating FROM film GROUP BY rating;

-- PG 또는 G 등급 
SELECT rating, COUNT(*) FROM film
WHERE rating='PG' OR rating='G'
GROUP BY rating;

-- 제목 조회
SELECT title, rating FROM film
WHERE rating='PG' OR rating='G'
ORDER BY rating, title;

-- 대여비가 1~6 이하
SELECT rating, COUNT(*)
	FROM film
    WHERE rental_rate BETWEEN 1 AND 6;

-- 등급별 영화의 수 출력
SELECT rating, COUNT(*)
	FROM film
    GROUP BY rating;

-- 대여비가 1~6 이하인 등급별 영화의 수 출력
SELECT rating, COUNT(*)
	FROM film
    WHERE rental_rate BETWEEN 1 AND 6
    GROUP BY rating;
    
-- 등급별 영화 수와 합계, 최고, 최저 rental_rate를 조회
SELECT rating 등급, COUNT(*) '해당 등급 영화 수',MAX(rental_rate) '최대 렌탈비',MIN(rental_rate) '최소 렌탈비' 
	FROM film
    GROUP BY rating;

-- 등급별 영화 개수, 등급, 평균 rental_rate 출력하고 내림차순 정렬
SELECT rating 등급, COUNT(*) '해당 등급 영화 수', AVG(rental_rate) '평균 렌탈 비용'
	FROM film
    GROUP BY rating
    ORDER BY '평균 렌탈 비용' DESC;
    
-- 분류가 family인 영화 film 테이블 서브쿼리 사용
SELECT title FROM film
WHERE film_id IN (SELECT film_id FROM film_category
WHERE category_id IN (SELECT category_id FROM category
WHERE name='Family'));

-- 영화 분류별 영화의 개수/ film,film_category,category 동등 조인 OR left 조인 활용
SELECT C.name '영화 분류', COUNT(*) '분류별 영화 개수' FROM film F
LEFT JOIN film_category FC ON F.film_id=FC.film_id
LEFT JOIN category C ON FC.category_id=C.category_id
GROUP BY C.name
ORDER BY COUNT(*);

-- action 영화의 이름, 영화수, 합계(rental_rate), 평균, 최소, 최고 집계
SELECT title '영화 이름' FROM film
WHERE film_id IN (SELECT film_id FROM film_category
WHERE category_id IN (SELECT category_id FROM category
WHERE name='Action'));

SELECT C.name, COUNT(*) '액션 영화 수', SUM(rental_rate) '렌탈비 합계', AVG(rental_rate) '렌탈비 평균', 
	   MIN(rental_rate) '렌탈비 최소', MAX(rental_rate) '렌탈비 최대' FROM film F, film_category FC
JOIN category C ON FC.category_id=C.category_id
WHERE FC.film_id=F.film_id
GROUP BY C.name, F.rental_rate
HAVING C.name='Action' ORDER BY '렌탈비 평균' DESC;

-- 가장 대여비가 높은 영화 분류/ category, film_category, inventory, payment, rental
SELECT C.name category_name, SUM(IFNULL(P.amount, 0)) REVENUE
	FROM category C
    LEFT JOIN film_category FC ON C.category_id=FC.category_id
    LEFT JOIN film F ON FC.film_id=F.film_id
    LEFT JOIN inventory I ON F.film_id=I.film_id
    LEFT JOIN rental R ON I.inventory_id=R.inventory_id
    LEFT JOIN payment P ON R.rental_id=P.rental_id
    GROUP BY C.name
    ORDER BY REVENUE DESC;
     

-- 뷰 생성(v_cat_revenue)/ category=name,category_name,SUM(IFNULL(pay.amount, 0) REVENUE
CREATE OR REPLACE VIEW v_cat_revenue AS SELECT C.name category_name, SUM(IFNULL(P.amount, 0)) REVENUE    
	FROM category C
    LEFT JOIN film_category FC ON C.category_id=FC.category_id
    LEFT JOIN film F ON FC.film_id=F.film_id
    LEFT JOIN inventory I ON F.film_id=I.film_id
    LEFT JOIN rental R ON I.inventory_id=R.inventory_id
    LEFT JOIN payment P ON R.rental_id=P.rental_id
    GROUP BY C.name
    ORDER BY REVENUE DESC;
SELECT * FROM v_cat_revenue limit 10;