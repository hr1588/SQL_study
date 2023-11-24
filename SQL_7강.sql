-- 1. 테이블 전체의 특징량 계산

select 
	count(*) as total_count, 
	count(distinct user_id) as user_count, 
	count(distinct product_id) as product_count,
	sum(score) as sum,
	round(avg(score),2) as avg,
	max(score) as max,
	min(score) as min
from review;

-- distinct : column에서 중복을 제외
-- 집약 함수 : 여러 레코드를 기반으로 하나의 값을 리턴하는 함수로, count, sum, max 등이 있다.

-- 2. Grouping한 데이터의 특징량 계산

select user_id, count(*) as total_count,
	count(distinct product_id) as product_count,
	sum(score) as sum,
	round(avg(score),2) as avg,
	max(score) as max,
	min(score) as min
from review
group by user_id;

-- SQL 구문 순서 : select -> from -> where -> group by -> having -> order by -> limit

-- 3. 윈도 함수를 사용해 집약 함수와 원래 값을 동시에 다루는 쿼리

select user_id, product_id, score,
	avg(score) over() as avg_score,
	avg(score) over(partition by user_id) as user_avg_score,
	score - avg(score) over(partition by user_id) as user_avg_score_diff
from review;

-- 집약 함수로 윈도 함수를 사용하려면, 집약 함수 뒤에 over를 붙이고 윈도 함수를 지정
-- over 안에 매개변수를 지정하지 않으면 테이블 전체에 집약 함수를 적용하고, partition by column을 지정하면 해당 column 값을 기준으로 그룹화 후 집약 함수를 적용
-- avg(score)와 avg(score) over()는 둘 다 평균을 계산하는 함수지만, order by 구문에서 집계 함수를 사용하면 오류가 발생한다.
-- 집계 함수를 사용하면 그룹 별로 하나의 결과값을 만들어 내지만, order by 구문은 각각의 행에 대해 작동하기 때문에 집계 함수를 사용할 수 없다. 반면 윈도우 함수는 각 행별로 값을 만들어내기 때문에, 사용가능

-- 4. 윈도 함수의 order by 구문으로 테이블 내부의 순서 정렬

select product_id, score,
	row_number() over(order by score desc) as row,
	rank() over(order by score desc) as rank,
	dense_rank() over(order by score desc) as dense_rank,
	lag(product_id) over(order by score desc) as lag1,
	lag(product_id,2) over(order by score desc) as lag2,
	lead(product_id) over(order by score desc) as lead1,
	lead(product_id,2) over(order by score desc) as lead2
from popular_products
order by row;

-- 윈도 함수 : 윈도우 함수는 행 집합에 대한 계산을 수행하는 함수로, 집계 함수와 달리 각 행에 대한 결과를 반환
-- row_number() : 순서에 유일한 순위 번호를 붙이는 함수
-- rank() : 같은 순위의 레코드가 있을 때 순위 번호를 동일하게 붙이고, 같은 순위 레코드 뒤의 순위 번호를 건너뜀
-- dense_rank() : 같은 순위의 레코드가 있을 때 순위 번호를 동일하게 붙이고, 순위 번호를 건너뛰지 않음
-- lag() : 현재 행을 기준으로 이전 행의 값을 가져옴
-- lead() : 현재 행을 기준으로 다음 행의 값을 가져옴

-- 5. order by 구문과 집약 함수 조합

select product_id, score,
	row_number() over(order by score desc) as row,
	sum(score) over(order by score desc rows between unbounded preceding and current row) as cum_score,
	avg(score) over(order by score desc rows between 1 preceding and 1 following) as local_avg,
	first_value(product_id) over(order by score desc rows between unbounded preceding and unbounded following) as first_value,
	last_value(product_id) over(order by score desc rows between unbounded preceding and unbounded following) as last_value
from popular_products
order by row;

-- 윈도 프레임 : 윈도우 함수가 적용될 행의 범위를 지정하는 것, 현재 레코드 위치를 기반으로 상대적인 윈도를 정의
-- 가장 기본적인 형태는 rows between start and end
-- start와 end에는 current row(현재 행), n preceding(n행 앞), n following(n행 뒤), unbounded preceding(이전 행 전부), unbounded following(이후 행 전부)를 지정
-- first_value(): 윈도 내부의 가장 첫 번째 레코드
-- last_value(): 윈도 내부의 가장 마지막 레코드
-- 윈도 함수에 프레임 지정을 하지 않으면, order by 구문이 없는 경우 모든 행, order by 구문이 있는 경우 첫 행에서 현재 행까지가 디폴트로 지정


-- 6. 윈도 프레임 지정별 상품 ID를 집약

select product_id,
	row_number() over() as row,
	array_agg(product_id) over(order by score desc rows between unbounded preceding and unbounded following) as whole_agg,
	array_agg(product_id) over(order by score desc rows between unbounded preceding and current row) as cum_agg,
	array_agg(product_id) over(order by score desc rows between 1 preceding and 1 following) as local_agg
from popular_products
where category = 'action'
order by row;

-- array_agg : 특정 column의 여러 행의 값을 하나의 배열로 집계하는데 사용. 단, 집계 함수의 일종이기 때문에 다른 column과 함께 사용하려면 group by 혹은 윈도우 함수를 사용해야 함.
-- hive, spark : array_agg 대신 collect_list 함수 사용

-- 7. 윈도 함수를 사용해 카테고리들의 순위를 계산

select category, product_id, score,
	row_number() over(partition by category order by score desc) as row,
	rank() over(partition by category order by score desc) as rank,
	dense_rank() over(partition by category order by score desc) as dense_rank
from popular_products;

-- 8. 카테고리들의 순위 상위 2개까지의 상품을 추출

select * 
from(select category, product_id, score,
	 row_number() over (partition by category order by score desc) as row
	 from popular_products)
where row <= 2
order by category, row;

-- 9. 카테고리별 순위 최상위 상품을 추출

select distinct category, 
	first_value(product_id) over (partition by category order by score desc
								 rows between unbounded preceding and unbounded following) as product_id
from popular_products;

-- 10. 행으로 저장된 값을 열로 변환

select dt, 
	max(case when indicator = 'impressions' then val end) as impressions,
	max(case when indicator = 'sessions' then val end) as sessions,
	max(case when indicator = 'users' then val end) as users
from daily_kpi
group by dt
order by dt;

-- 원본 데이터에서 날짜별로 지표가 하나씩 존재하므로, Case 조건식의 조건이 True가 되는 조건도 하나이다. 따라서, Max로 추출 가능

-- 11. 행을 집약해서 쉼표로 구분된 문자열로 변환

select purchase_id, 
	string_agg(product_id, ',') as product_ids,
	sum(price) as amount
from purchase_detail_log
group by purchase_id
order by purchase_id;

-- string_agg(val, ',') : 행을 집약해서, 쉼표로 구분된 문자열로 변환
-- redshift : string_agg 대신 listagg 함수 사용

-- 12. 일련 번호를 가진 피벗 테이블을 사용해 행으로 변환

select q.year, case
	when p.idx = 1 then 'q1'
	when p.idx = 2 then 'q2'
	when p.idx = 3 then 'q3'
	when p.idx = 4 then 'q4'
	end as quarter, case
	when p.idx = 1 then q.q1
	when p.idx = 2 then q.q2
	when p.idx = 3 then q.q3
	when p.idx = 4 then q.q4
	end as sales
from quarterly_sales as q
cross join
(select 1 as idx
union all select 2 as idx
union all select 3 as idx
union all select 4 as idx)
as p
;

-- cross join을 사용하여 각 연도의 각 분기에 대한 모든 조합을 생성하지만, 비효율적임

SELECT year, 'q1' AS quarter, q1 AS sales FROM quarterly_sales
UNION ALL
SELECT year, 'q2', q2 FROM quarterly_sales
UNION ALL
SELECT year, 'q3', q3 FROM quarterly_sales
UNION ALL
SELECT year, 'q4', q4 FROM quarterly_sales
order by year, quarter;

-- year와 q1에 해당하는 값을 뽑고, 중간에 행의 개수만큼 'q1'이라는 문자열을 추가
-- pandas의 melt 함수와 유사한 역할을 수행

-- 13. 테이블 함수를 사용해 배열을 행으로 전개

select unnest(array['A001','A002','A003']) as product_id;

-- unnest : 배열을 입력으로 받아, 각 배열 요소를 별도의 행으로 반환
-- bigquery : unnest 함수를 사용하지만, 테이블 함수를 from 구문 안에서만 사용 가능
-- hive, spark : unnest 대신 explode 함수 사용

-- 14. 테이블 함수를 사용해 쉼표로 구분된 문자열 데이터를 행으로 전개

select purchase_id, unnest(string_to_array(product_ids,',')) as product_id
from purchase_log;

-- string_to_array : 문자열을 배열로 변환

select purchase_id, regexp_split_to_table(product_ids,',') as product_id
from purchase_log;

-- regexp_split_to_table : postgresql에서만 사용 가능, 쉼표로 구분된 문자열을 한 번에 행으로 전개 가능

-- 15. 문자 수의 차이를 사용해 상품 수를 계산(post, redshift)

select purchase_id, product_ids,
	1 + char_length(product_ids) - char_length(replace(product_ids,',','')) as product_num
from purchase_log;

-- char_length : 문자열의 길이를 return
-- 쉼표의 개수 + 1을 구해서 전체 상품의 개수 파악

-- 16. 피벗 테이블을 사용해 문자열을 행으로 전개(post, redshift)

select l.purchase_id, l.product_ids, p.idx, split_part(l.product_ids,',',p.idx) as product_id
from purchase_log as l
join (
select 1 as idx
union all select 2 as idx
union all select 3 as idx)
as p
on p.idx <= (1+char_length(l.product_ids) - char_length(replace(l.product_ids,',','')));

-- join 조건으로 idx가 상품의 id보다 큰 경우를 제외하고 출력

SELECT l.purchase_id, l.product_ids, p.idx,
    split_part(l.product_ids,',',p.idx) as product_id
FROM purchase_log as l
JOIN generate_series(1, 100) as p(idx)
ON p.idx <= (1+char_length(l.product_ids) - char_length(replace(l.product_ids,',','')))
order by purchase_id;

-- 제품의 개수가 많아지는 경우, index를 직접적으로 모두 나열하는 것은 불가능
-- generate_series(start, end) 함수를 사용하면, 숫자를 생성가능








