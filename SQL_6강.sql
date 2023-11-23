--1. 문자열 연결하기
select user_id, concat(pref_name, city_name) as name 
from mst_user_location;
-- concat 함수 사용
-- post, redshift는 || 연산자도 사용 가능

--2. 컬럼을 비교하기
select year, q1,q2, case 
	when q1 < q2 then '+'
	when q1 = q2 then ''
	when q1 > q2 then '-'
end as judge_q1_q2,
	q2-q1 as diff_q2_q1,
	sign(q2-q1) as sign_q2_q1
from quarterly_sales;
-- case when, sign 함수 활용
-- sing 함수 : 양수라면 1, 0이라면 0, 음수라면 -1을 return

--3.연간 최대/최소 매출을 찾는 쿼리
select year, greatest(q1,q2,q3,q4), least(q1,q2,q3,q4)
from quarterly_sales;
-- greatest : 컬럼에서 최댓값, least : 컬럼에서 최솟값

--4.평균 매출을 구하는 쿼리
select year, (q1+q2+q3+q4) / 4 as mean
from quarterly_sales
order by year;

select year, 
	(coalesce(q1,0)+coalesce(q2,0)+coalesce(q3,0)+coalesce(q4,0))/4 as mean
from quarterly_sales;

select year,
	(coalesce(q1,0)+coalesce(q2,0)+coalesce(q3,0)+coalesce(q4,0))/
	(sign(coalesce(q1,0))+sign(coalesce(q2,0))+sign(coalesce(q3,0))+sign(coalesce(q4,0)))as mean
from quarterly_sales;

-- sign 함수를 사용해서, 해당 년도에 매출이 존재하지 않는 분기는 계산에서 제외

--5.정수 자료형 분할

select dt, ad_id, 
	cast(clicks / impressions as double precision) as ratio,
	100.0 * clicks / impressions as per
from advertising_stats
where impressions != 0;

select dt, ad_id, 
	cast(clicks as double precision) / impressions as ratio,
	round(100.0 * clicks / impressions,2) as per
from advertising_stats
where impressions != 0;
-- SQL은 기본적으로 정수 나누기 정수는 정수를 반환한다. 즉, 이미 정수로 반환된 값을 cast로 변환하니 정수가 출력되는 것
-- 실수를 상수로 앞에 두면 암묵적 자료형 변환이 발생
-- double precision : double 자료형

--6. 0으로 나누는 것 피하기
select dt, ad_id, case
	when impressions > 0 then round(100.0 * clicks / impressions,2)
	end as per,
	round(100.0*clicks / nullif(impressions, 0),2) as per_null
from advertising_stats;

-- where절로 0을 제거하면 해당하는 행 전체가 사라진다.
-- case when 혹은 nullif(val,0)을 사용하면, 행을 유지한 상태로 계산할 수 있다.

--7.1차원 데이터 차이 절댓값과 RMSE 계산
select abs(x1-x2) as abs, sqrt(power(x1-x2,2)) as rmse from location_1d;

-- abs : 절대값 함수, sqrt : 제곱근 함수, power : 제곱 함수

--8.2차원 데이터 rmse 계산
select sqrt(power(x2-x1,2)+power(y2-y1,2)) as dist from location_2d;
select point(x1,y1) <-> point(x2,y2) as dist from location_2d;

-- sqrt, power 함수 활용, post는 point와 <-> 연산자 사용 가능

--9.미래 또는 과거의 날짜/시간 계산
select user_id, register_stamp, 
	cast(register_stamp as timestamp) + interval '1 hour' as after_1_hour,
	cast(register_stamp as timestamp) - interval '30 minutes' as before_30_minutes,
	cast(register_stamp as date),
	cast(cast(register_stamp as date) + interval '1 day' as date) as after_1_day,
	cast(cast(register_stamp as date) - interval '1 month' as date) as before_1_month
from mst_users_with_dates; 

-- post : interval 키워드로 시간 간격 표시
-- redshift : dateadd 함수 사용 ex) dateadd(hour,1,register_stamp::timestamp), dateadd(month, -1, register_stamp::date)
-- bigquery : timestamp_add/sub, date_add/sub 사용 ex) data_add(date(timestamp(register_day)), interval 1 day)
-- Hive, spark : 날짜/시각 계산 함수가 없음. from_unixtime으로 초 단위 계산을 적용한 뒤 다시 timestamp로 변환 / to_date : 문자열 날짜로 변환 / date_add, add_months 함수 활용

-- 10. 두 날짜 데이터들의 차이 계산

select user_id, current_date as today, register_stamp::date, current_date-cast(register_stamp as date) as diff_days
from mst_users_with_dates;

-- cast 함수를 사용하거나, ::뒤에 형식을 지정해서 날짜 형식 사용 가능
-- bigquery : date_diff 함수 사용
-- hive, spark : datediff 함수 사용

-- 11. age 함수를 사용해 나이를 계산하는 쿼리

select user_id, current_date as today, register_stamp::date as register_date, birth_date::date, 
	extract(year from age(birth_date::date)), extract(year from age(register_stamp::date, birth_date::date)) as register_age
from mst_users_with_dates;

-- age 함수를 사용해 나이를 계산할 수 있다. 단, 인자의 개수에 따라 계산 방식이 달라진다.
-- 인자가 하나인 경우 오늘을 기준으로 첫 번째 인자를 뺀 나이(연,월,일)을 계산하고, 인자가 2개이면 첫 번째 인자에서 두 번째 인자를 뺀 나이(연,월,일)을 반환한다. 최대 2개의 인자까지만 허용된다.

-- 12. 날짜를 정수로 표현해서 나이를 계산

select floor((20231120-20020319) / 10000) as age;
-- floor 함수 : 주어진 숫자보다 작거나 같은 가장 큰 정수를 반환(나이를 연도로 계산하려면 내림해야 함)

-- 13. 등록 시점과 현재 시점의 나이를 문자열로 계산

select 
	user_id, register_stamp, birth_date,
	floor((cast(replace(substring(register_stamp,1,10),'-','') as integer) - cast(replace(birth_date,'-','') as integer))/10000) ,
	floor((cast(replace(cast(current_date as text),'-','') as integer) - cast(replace(birth_date,'-','') as integer))/10000) as age
from mst_users_with_dates;

-- floor, cast, replace, substring 함수를 활용, 비효율적임

-- 14. inet 자료형을 사용한 IP 주소 비교

select 
	cast('127.0.0.1' as inet) < cast('127.0.0.2' as inet) as lt,
	cast('127.0.0.1' as inet) > cast('192.168.0.1' as inet) as gt;
	
-- inet 자료형 : ip 주소를 다루기 위한 자료형
-- True or False로 return

-- 15. inet 자료형을 사용해 IP 범위 주소를 확인(포함 여부)

select cast('127.0.0.1' as inet) << cast('127.0.0.0/8' as inet) as contain; 

-- True or False로 return

-- 16. IP 주소에서 4개의 10진수 부분을 추출

select ip,
	cast(split_part(ip,'.',1) as integer) as ip_part_1,
	cast(split_part(ip,'.',2) as integer) as ip_part_2,
	cast(split_part(ip,'.',3) as integer) as ip_part_3,
	cast(split_part(ip,'.',4) as integer) as ip_part_4
from (select '192.168.0.1' as ip) as t;

-- 17. IP 주소를 정수 자료형 표기로 변환

select ip,
	 cast(split_part(ip,'.',1) as integer) * 2^24
	+cast(split_part(ip,'.',2) as integer) * 2^16
	+cast(split_part(ip,'.',3) as integer) * 2^8
	+cast(split_part(ip,'.',4) as integer) * 2^0
	as ip_integer
from (select '192.168.0.1' as ip) as t;

-- split_part : 문자열 분할 함수로, 특정 구분자로 분할 후 지정된 위치의 값을 반환
-- bigquery, hive, spark : split 함수로 배열 분해, n번째 요소 추출
-- ipv4 주소는 4개의 8비트(1byte) 주소로 구성되며, 각 세그먼트는 0부터 255까지의 정수를 가진다. 이를 2진수로 변환하려면 각 세그먼트를 해당 위치의 2의 제곱으로 곱해줘야 한다.

-- 17. ip 주소를 0으로 채운 문자열로 반환하는 쿼리

select ip,
	lpad(split_part(ip,'.',1),3,'0')||
	lpad(split_part(ip,'.',2),3,'0')||
	lpad(split_part(ip,'.',3),3,'0')||
	lpad(split_part(ip,'.',4),3,'0')
from (select '192.168.0.1' as ip) as t;

-- lpad : 문자열의 왼쪽에 특성 문자를 추가하여 주어진 길이로 만드는 역할을 수행, 만약 원래 문자열의 길이가 이미 주어진 길이보다 길다면, 문자열은 잘린다.
-- || 연산자로 문자열을 연결









