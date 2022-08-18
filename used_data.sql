-- 1. 월별 관심도 3위까지 
with main as(
select year1, month1, category, round(avg(value),0) avg,
rank() over(partition by year1, month1 order by avg(value) desc) ranks 
from interest
group by year1, month1,category)
select year1, month1,category,avg,ranks
from main
where ranks <= 3;

-- 2. 월별 카드사용량 3위
with main as(
select year1, month1, category, round(avg(value),0) avg,
rank() over(partition by year1, month1 order by avg(value) desc) ranks
from card
group by year1, month1,category)
select year1, month1, category,avg,ranks
from main 
where ranks <=3;

-- 3. 코로나 데이터 + 카드사용 통계 
-- 3-1) 코로나 거리두기 단계 별 카드사용량 비교(7월 4주차 까지의 데이터)
with a as(
select covid19_year years, covid19_month months, covid19_level level ,avg(covid19_infection) inf
from covid_data_food
group by 1,2,3),
b as(
select year1, month1, avg(value) val
from card
group by year1, month1)
select level, round(avg(inf),0) inf,count(*) 개월수 , round(avg(val),0) val
from a,b
where a.years = b.year1 and a.months = b.month1
group by level;
-- ----> 결론 : 거리두기 해제에 따라 카드소비 비율이 증가하였다.


-- 3-2) 코로나 거리두기 단계에 따라 음식 관심도 (8월 1주차까지의 데이터)
with a as(
select covid19_year years, covid19_month months, covid19_level level ,avg(covid19_infection) inf
from covid_data_food
group by 1,2,3),
b as (
select year1, month1, avg(value) val
from interest
group by year1, month1)
select level, round(avg(inf),0) inf, count(*) 개월수, round(avg(val),0)
from a, b
where a. years = b.year1 and a.months = b.month1
group by level;
-- ----> 결론 : 거리두기 해제에 따라 음식에 대한 관심도가 증가하였다.


-- 4. 관심도 + 카드사용통계 
-- 관심도 : 지역별 네이버에 검색한 데이터를 종합하여 도출한 값
-- 카드사용통계 : BC카드에서 제공하는 데이터를 기반으로 도출한 카드 사용내역

-- 4-1) 관심도 1,2,3위인 값의 카드사용 순위 
with a as(
select year1, category, round(avg(value),0) 관심도,
rank()over(partition by year1 order by round(avg(value),0) desc) 관심도순위
from interest
group by category),
b as(
select year1, category, round(avg(value),0) 카드사용,
rank()over(partition by year1 order by round(avg(value),0) desc) 카드사용순위
from card
group by category)
select a.category, a.관심도,a.관심도순위, b.카드사용, b.카드사용순위
from a, b
where a.year1 = b.year1 and a.category = b.category
and a.관심도순위 <=3
order by 3;

-- 4-2) 카드사용 순위 1,2,3위의 관심도 순위
with a as(
select year1, category, round(avg(value),0) 관심도,
rank()over(partition by year1 order by round(avg(value),0) desc) 관심도순위
from interest
group by category),
b as(
select year1, category, round(avg(value),0) 카드사용,
rank()over(partition by year1 order by round(avg(value),0) desc) 카드사용순위
from card
group by category)
select a.category, a.관심도,a.관심도순위, b.카드사용, b.카드사용순위
from a, b
where a.year1 = b.year1 and a.category = b.category
and b.카드사용순위 <=3
order by 5;

-- ----> 결론 : 관심도 1위 = 2년 모두 '한식' / 카드사용 1위 = '서양식' , '주점'
--             사람들의 검색량(관심도)가 높다고 해서 카드사용량도 많은것은 아님. 
--             ====> 창업을 한다면 카페 또는 주점


-- 4-3) 카페 창업시 마케팅 타겟층은 누가 좋을까??
select category,gender, age, round(avg(value),0) 카드사용량,
rank()over(order by avg(value) desc) 카드사용순위
from card
where category = '카페,디저트'
group by gender, age;
-- ----> 결론 : 50대 여성을 타겟층으로

-- 4-4) 주점 창업시 마케팅 타겟층은 누가 좋을까??
select category,gender, age, round(avg(value),0) 카드사용량,
rank()over(order by avg(value) desc) 카드사용순위
from card
where category = '주점'
group by gender, age;
-- ----> 결론 : 20대 여성을 타겟층으로



-- 5. 코로나 단계별 소비 왕은??
-- 5-0) 전체
select a.covid19_level, b.gender, b.age, avg(value),
rank()over(partition by a.covid19_level order by avg(value))
from covid_data_food a, card b
where a.covid19_year = b.year1 and a.covid19_month = b.month1
group by a.covid19_level, b.gender, b.age;

-- 5-1) 4단계 적용
select a.covid19_level, b.gender, b.age, avg(value) 카드사용량,
rank()over(partition by a.covid19_level order by avg(value) desc) 카드사용순위
from covid_data_food a, card b
where a.covid19_year = b.year1 and a.covid19_month = b.month1
and a.covid19_level = 'level4'
group by a.covid19_level, b.gender, b.age;
-- ----> 결론 : 50대 여성이 1위

-- 5-2) 일상회복 돌입
select a.covid19_level, b.gender, b.age, avg(value) 카드사용량,
rank()over(order by avg(value) desc) 카드사용순위
from covid_data_food a, card b
where a.covid19_year = b.year1 and a.covid19_month = b.month1
and a.covid19_level = 'recovery'
group by a.covid19_level, b.gender, b.age;
-- ----> 결론 : 50대 여성이 1위

-- 5-3) 거리두기 해제
select a.covid19_level, b.gender, b.age, avg(value)카드사용량,
rank()over(order by avg(value)desc) 카드사용순위
from covid_data_food a, card b
where a.covid19_year = b.year1 and a.covid19_month = b.month1
and a.covid19_level = 'clear'
group by a.covid19_level, b.gender, b.age;
-- ----> 결론 : 50대 여성이 1위

-- ========> 50대 여성이 전체적으로 카드사용 1위

-- 5-4) 50대 여성을 타겟층으로 한 창업은 어떤게 좋을까??
select category, round(avg(value),0) 카드사용량,
rank()over(order by avg(value) desc) 카드사용순위
from card
where gender = '여자' and age = '50대'
group by category;
-- ----> 결론 : '카페,디저트' 가 1위

-- ========> 최종 결론 : '50대 여성'을 타겟층으로 한 '카페,디저트' 창업










-- 코로나값에 따른 카드사용통계 확인
select *
from(
select year1, month1, sum(value),
rank() over(order by sum(value) desc) ranks
from card
group by 1,2) a
where a.year1 = 2022
and a.month1 = 5;



