# 서울 한정으로 진행
-- 전체 관심도 확인 (한식, 카페 디저트, 분식)
select category, sum(value),
rank() over(order by sum(value) desc)순위
from interest
group by category;

-- 전체 카드 사용 비율 (주점, 서양식 아시아 음식, 카페 디저트)
select category, sum(value),
rank() over(order by sum(value) desc)순위 
from card
group by category;


-- 거리두기 변화에 따른 음식점 관심 확인
-- 전체적으로 변화될 때마다 음식점 관심은 높아진다.
-- 결론 : 코로나와 관계없이 음식점에 대한 관심은 계속 올라간다.
with a as(
select covid19_year years, covid19_month months, covid19_level level ,avg(covid19_infection) inf
from covid19_data_food
group by 1,2,3),
b as (
select year1, month1, avg(value) val
from interest
group by year1, month1)
select level, round(avg(inf),0) inf, count(*) 개월수, round(avg(val),0)
from a, b
where a. years = b.year1 and a.months = b.month1
group by level;

-- 거리두기 변화에 따른 카드 사용 비율 확인
-- 추가적인 데이터 확인이 필요하지만 대략적으로 카드 사용 비율이 높아지고 있음을 확인
-- > level4에서는 코로나에 대한 경각심, 음식점 문 닫는 시간
-- > level4에서 일상회복으로 돌아간 반동으로 코로나 확진자 수는 대폭 상승 했음에도 카드 사용 비율이 늘어난 것을 확인
-- > 해제 코로나 확진자 수가 일상회복 때보다 크게 감소 함으로 사용자들이 평범한 일상으로 돌아왔다고 판단하여 카드 사용 비율이 늘어난 것으로 확인 
with a as(
select covid19_year years, covid19_month months, covid19_level level ,avg(covid19_infection) inf
from covid19_data_food
group by 1,2,3),
b as(
select year1, month1, avg(value) val
from card
group by year1, month1)
select level, round(avg(inf),0) inf,count(*) 개월수 , round(avg(val),0) val
from a,b
where a.years = b.year1 and a.months = b.month1
group by level;


-- 년도별 관심도 3위까지 기준으로 카드사용 순위 확인 시 관심도와 카드 사용 비율이 결과가 다름을 확인
-- 한식 관심도 1위, 카드 사용순위 5위
-- 카폐 디저트 2위, 카드 사용순위 3위
-- 분식 3위 카드 사용 순위 7위
-- > 적절한 관심을 가지며 카드 사용순위에도 높은 카폐, 디저트가 서울에서 창업하기 유리함을 확인
with a as(
select year1, category, round(avg(value),0) 관심도,
rank()over(partition by year1 order by round(avg(value),0) desc) 관심도순위
from interest
group by year1, category),
b as(
select year1, category, round(avg(value),0) 카드사용,
rank()over(partition by year1 order by round(avg(value),0) desc) 카드사용순위
from card
group by year1, category)
select a.year1, a.category, a.관심도,a.관심도순위, b.카드사용, b.카드사용순위
from a, b
where a.year1 = b.year1 and a.category = b.category
and a.관심도순위 <=3
order by 1,4;


-- 년도별 카드 사용 순위 3위까지 기준으로 관심도 확인
-- 주점
with a as(
select year1, category, round(avg(value),0) 관심도,
rank()over(partition by year1 order by round(avg(value),0) desc) 관심도순위
from interest
group by year1, category),
b as(
select year1, category, round(avg(value),0) 카드사용,
rank()over(partition by year1 order by round(avg(value),0) desc) 카드사용순위
from card
group by year1, category)
select a.year1, a.category, a.관심도,a.관심도순위, b.카드사용, b.카드사용순위
from a, b
where a.year1 = b.year1 and a.category = b.category
and b.카드사용순위 <=3
order by 1,5 desc;
-- 관심은 크게 없으면서도 카드를 많이 사용하는 업종 : 주점
-- 관심도 가지고 있으면서 카드를 많이 사용하는 업종 : 카페, 디저트


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

# 코로나 단계별 소비 비율

-- 4단계 여성 50대 카드 사용 순위 1위
select a.covid19_level, b.gender, b.age, avg(value) 카드사용량,
rank()over(partition by a.covid19_level order by avg(value) desc) 카드사용순위
from covid19_data_food a, card b
where a.covid19_year = b.year1 and a.covid19_month = b.month1
and a.covid19_level = 'level4'
group by a.covid19_level, b.gender, b.age;

-- 일상회복 여성 50대 카드 사용 순위 1위
select a.covid19_level, b.gender, b.age, avg(value) 카드사용량,
rank()over(order by avg(value) desc) 카드사용순위
from covid19_data_food a, card b
where a.covid19_year = b.year1 and a.covid19_month = b.month1
and a.covid19_level = 'recovery'
group by a.covid19_level, b.gender, b.age;

-- 해제 여성 50대 카드 사용 순위 1위
select a.covid19_level, b.gender, b.age, avg(value)카드사용량,
rank()over(order by avg(value)desc) 카드사용순위
from covid19_data_food a, card b
where a.covid19_year = b.year1 and a.covid19_month = b.month1
and a.covid19_level = 'clear'
group by a.covid19_level, b.gender, b.age;

-- 50대 여성이 카페, 디저트에서 유리한데 다른 업종에서도 많이 사용 하지 않았을까? 
-- 50대 여성을 타겟층으로 창업은 어떤 것이 좋은가?
-- 카폐, 디저트 1위 
select category, round(avg(value),0) 카드사용량,
rank()over(order by avg(value) desc) 카드사용순위
from card
where gender = '여자' and age = '50대'
group by category;

