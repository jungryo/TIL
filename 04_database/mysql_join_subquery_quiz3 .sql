# 소수점 올림, 반올림, 버림 함수 
select ceil(12.345);
select round(12.345, 2);
select truncate(12.345, 2);

select Code,  round(GNP/Population*1000, 2)
from country;

#	조건문 

# IF : IF(조건, 참, 거짓)
# 도시의 인구가 100만 이상이면 big city, 100만 미만이면 small city 출력
# column: city_scale
use world
select name, population, if(population >= 1000000, "big city", "small city") 
as city_scale
from city;

# IFNULL: IFNUU(참, 거짓)
# country 테이블에서 독립년도(IndepYear)가 없으면 0으로 출력
Select Name, IFNULL(IndepYear, 0) as IndepYear
from country;


# CASE
# CASE
#     WHEN (조건1) TEHN (출력1)
#     WHEN (조건2) TEHN (출력2)
# END AS (컬럼명)

# 나라별 10억이상, 1억이상, 1억이하 조건을 출력 

select name, population,
CASE 
	WHEN population > 1000000000 THEN "upper 1 billion"
	WHEN population > 100000000 THEN "upper 100 million"
	ELSE "below 100 million"
END as result
from country;

# DATE_FORMAT: 날짜데이터의 포맷을 변경해주는 함수
# sakila
use sakila;

# payment 에서 월별 총 매출 출력
select DATE_FORMAT(payment_date, "%h") as hourly, sum(amount), count(amount) 
from payment
group by hourly;
# group by payment_date

# JOIN: merge()
CREATE TABLE user (user_id int(11) unsigned NOT NULL AUTO_INCREMENT,name varchar(30) DEFAULT NULL,PRIMARY KEY (user_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE addr (id int(11) unsigned NOT NULL AUTO_INCREMENT,addr varchar(30) DEFAULT NULL,user_id int(11) DEFAULT NULL,PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO user(name)VALUES ("jin"),("po"),("alice"),("petter");

INSERT INTO addr(addr, user_id)VALUES ("seoul", 1),("pusan", 2),("deajeon", 3),("deagu", 5),("seoul", 6);


# inner join
select addr.addr, addr.user_id, user.name
from addr
join user
on addr.user_id = user.user_id;

# world 도시이름, 국가이름을 출력
select city.countrycode, city.name as city_name, country.name as country_name
from city
join country
on city.countrycode = country.code;

# left join
select id, addr.addr, addr.user_id, Ifnull(user.name, "-")
from addr
left join user
on addr.user_id = user.user_id;

# right join
select id, ifnull(addr.addr, "-"), user.user_id, user.name
from addr
right join user
on addr.id = user.user_id;

# union : select	문의 결과를 합쳐서 출력 
# 자동으로 중복을 제거
select name
from user
union all 
select addr
from addr;

# ourter join
select user.name, addr.addr, user.user_id
from user
left join addr
on user.user_id = addr.user_id
union
select user.name, addr.addr, addr.user_id 
from user
right join addr
on user.user_id = addr.user_id;

# sub-query : 쿼리문 안에 쿼리가 있는 문법
# select, from, where

# 전체 나라수, 전체 도시수, 전체 언어수를 출력
select
(select count(*)
from country) as total_country,
(select count(*)
from city) as total_city,
(select count(distinct(language))
from countrylanguage) as total_language;


# 800만 이상이 되는 도시의 국가코드, 도시이름, 국가이름, 도시인구수를 출력

select *
from
	(select countrycode, name, population
	from city
	where population>8000000) as city
join
	(select code, name from country) as country
on city.countrycode = country.code;


# 800만 이상 도시의 국가코드, 국가이름, 대통령이름 출력
select code, name, HeadOfState
from country
where code in ( 
	select distinct(countrycode)
	from city
	where population >= 8000000
);

# index: 데이터를 검색할 때 빠르게 찾을수 있도록 해주는 기능
use employees;

explain
select count(*)
from salaries
where to_date > "2000-01-01";

create index tdate
on salaries (to_date);

explain
select count(*)
from salaries
where to_date > "2000-01-01";

drop index tdate
on salaries;

# view : 특정 쿼리문에 대한 결과를 저장하는 개념
use world

create view code_name as
select code, name
from country;

select * 
from city 
join (select code, name
from country) as code_name
on city.countrycode = code_name.code;

#select * 
#from city 
#join code_name
#on city.countrycode = code_name.code


# quiz 3 - join & sub-query# 1. 멕시코(Mexico)보다 인구가 많은 나라이름과 인구수를 조회하시고 인구수 순으로 내림차순하세요.

select name, population
from country
where population > (select population
from country
where name = "Mexico")
order by population DESC;


# 2. 국가별 몇개의 도시가 있는지 조회하고 도시수 순으로 10위까지 내림차순하세요.

select country.name, count(country.Code) as count
from city
join country
on city.CountryCode = country.code
Group by country.code
order by count DESC
limit 10;

# 3. 언어별 사용인구를 출력하고 언어 사용인구 순으로 10위까지 내림차순하세요.

# 국가별 인구와 언어 조인
select country.code, country.population, countrylanguage.language, countrylanguage.percentage
from country
join countrylanguage
on country.code = countrylanguage.countrycode;

# 언어별 사용인구 계산
select language, 
		round(sum(population * percentage/100),0) as count
from (select country.code, country.population,
	 	countrylanguage.language, countrylanguage.percentage
		from country
		join countrylanguage
		on country.code = countrylanguage.countrycode) as b
group by language
order by count DESC
limit 10;

# 4. 나라 전체 인구의 10%이상인 도시에서 도시인구가 500만이 넘는 도시를 아래와 같이 조회 하세요.

select co.Name, ci.CountryCode, ci.name, round((ci.population *100/co.population), 2) as percentage
from country as co
right join city as ci
on co.code = ci.CountryCode
where ci.population > 5000000
Having percentage > 10
order by percentage Desc;

# 5. 면적이 10000km^2 이상인 국가의 인구밀도(1km^2 당 인구수)를 구하고 인구밀도가 200이상인 국가들의 사용하고 있는 언어수가 5가지 이상인 나라를 조회 하세요.

# 면적이 10000km^2 이상인 국가의 인구밀도(1km^2 당 인구수)를 구하고
select code, name,round((population / SurfaceArea),0) as density
from country
where surfacearea > 10000 
Order by density DESC;

# 인구밀도가 200이상인 국가들
select code, name,round((population / SurfaceArea),0) as density
from country
where surfacearea > 10000 
Having density > 200
Order by density DESC;

# 언어수가 5가지 이상인 나라

select countrycode, count(language) as language_count
from countrylanguage
group by CountryCode
having language_count >= 5;

# join

select pop_dens.name, lan_co.language_count
from (select code, name,round((population / SurfaceArea),0) as density
from country
where surfacearea > 10000 
Having density > 200
Order by density DESC) as pop_dens
join (select countrycode, count(language) as language_count
from countrylanguage
group by CountryCode
having language_count >= 5) as lan_co
on lan_co.countrycode = pop_dens.code
order by language_count Desc;


# 6. 사용하는 언어가 3가지 이하인 국가중 도시인구가 300만 이상인 도시를 아래와 같이 조회하세요.

# 사용하는 언어 3가지 이하국가
select countrycode, count(language) as language_count, group_concat(language) as languages
from countrylanguage
group by CountryCode
having language_count <= 3 ;

# 도시인구 300만 이상인 도시 

select countrycode, name as city_name, population 
from city
where population >= 3000000;


# join

select lan.countrycode, big_city.city_name, big_city.population, lan.language_count, lan.languages
from (select countrycode, count(language) as language_count, group_concat(language) as languages
from countrylanguage
group by CountryCode
having language_count <= 3) as lan
join (select countrycode, name as city_name, population 
from city
where population >= 3000000) as big_city
on lan.countrycode = big_city.countrycode
order by big_city.population desc;

# final
select join_.* , country.name
from 
(select lan.countrycode, big_city.city_name, big_city.population, lan.language_count, lan.languages
from (select countrycode, count(language) as language_count, group_concat(language) as languages
from countrylanguage
group by CountryCode
having language_count <= 3) as lan
join (select countrycode, name as city_name, population 
from city
where population >= 3000000) as big_city
on lan.countrycode = big_city.countrycode
) as join_
join country
on country.code = join_.countrycode
order by population desc;


# view : 특정 쿼리문에 대한 결과를 저장하는 개념
create view big_city as
select city.countrycode, city.name as city_name, city.population, country.name 
from city
left join country
on country.code = city.countrycode
where city.population >= 3000000;

create view lan as 
select countrycode, count(language) as language_count, group_concat(language) as languages
from countrylanguage
group by CountryCode
having language_count <= 3;

select big_city.* , lan.language_count, lan.languages
from big_city
join lan
on big_city.countrycode = lan.countrycode
order by population desc; 
