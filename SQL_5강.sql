-- 1. 코드 값을 레이블로 변경하기
select user_id, 
	CASE 
		WHEN register_device = 1 THEN '데스크톱'
		WHEN register_device = 2 THEN '스마트폰'
		WHEN register_device = 3 THEN '애플리케이션'
		-- ELSE (default value)
	END AS device_name
from mst_users;

-- 주의 : THEN 뒤의 문자열에 "" 사용 불가

-- 2. refer domain 추출

select stamp, substring(referrer from 'https?://([^/]*)') as referrer_host
from access_log;

-- 정규식 : http:// 혹은 https://로 시작하고, 그 다음 /가 나오기 전까지의 모든 문자열 추출
-- redshift : regexp_substr + regexp_replace
-- hive, Sparksql : parse_url
-- bigquery : host

-- 3. URL에서 경로와 Get 매개변수 추출

select stamp, url, 
substring(url from '//[^/]+([^?#]+)') as path, substring(url from 'id=([^&]*)') as id
from access_log;

-- 정규식 : 스키마와 도메인을 제외한 /로 시작하는 부분부터 ? 또는 #이 나오기 전까지를 추출, URL에서 id= 뒤에 오는 부분을 &가 나오기 전까지 추출
-- redshift : regexp_substr + regexp_replace
-- hive, Sparksql : parse_url
-- bigquery : 정규식, regexp_extract

-- 4. URL 경로를 슬래시로 분할, 계층 추출

select stamp, url, 
split_part(substring(url from '//[^/]+([^?#]+)'),'/',2) as path1,
split_part(substring(url from '//[^/]+([^?#]+)'),'/',3) as path2
from access_log;

-- 정규식 : URL 필드에서 // 뒤에 /를 기준으로 문자를 분할하고, 두 번째, 세 번째 필드로 반환
-- redshift : split_part(regexp_substr + regexp_replace)
-- hive, Sparksql : split(인덱스가 0부터 시작)
-- bigquery : split(별도 인덱스 지정 필요)

-- 5. 현재 날짜와 timestamp를 추출

select current_date as dt, current_timestamp as stamp, 
localtimestamp as local_stamp;

-- current_timestamp - timezone이 적용된 timestamp(세계 시간기준), localtimestmap - timezone이 적용되지 않은 timestamp(DB local Time 기준)
-- hive, bigquery : current_date, current_timestamp 사용
-- hive, bigquery, Sparksql : current_date(), current_timestamp() 사용
-- redshift : 현재 날짜 - current_date, 현재 timestamp - getdate() 사용

-- 6. 문자열을 날짜, timestamp 자료형으로 변환

select cast('2016-01-30' as date) as dt, cast('2016-01-30' as timestamp) as stamp,
'2016-01-30'::date as dt2;

-- 교재 DB 5종 모두 cast(value as type) 사용 / type value도 사용 가능 ex) date '2016-01-30' as dt
-- hive, bigquery : type(value) ex) date('2016-01-30') as dt
-- postgreSQL, redshift : 'value::type' 사용

-- 7. Timestamp 자료형의 데이터에서 연, 월, 일을 추출

select stamp,
	extract(year from stamp) as year,
	extract(month from stamp) as month,
	extract(day from stamp) as day,
	extract(hour from stamp) as hour
from
	(select cast('2016-01-30 12:00:00' as timestamp) as stamp) as t;

-- post, red, big : extract 함수 사용
-- hive, spark : year(stamp), month(stamp), day(stamp), hour(stamp) 사용

-- 8. Timestamp를 나타내는 문자열 데이터에서 연, 월, 일을 추출

select stamp, 
	substring(stamp,1,4) as year,
	substring(stamp,6,2) as month,
	substring(stamp,9,2) as day,
	substring(stamp,12,2) as hour,
	-- 연과 월을 함께 추출
	substring(stamp,1,7) as year_month
from (select cast('2016-01-30 12:00:00' as text) as stamp) as t;

-- 주의점 : 7번은 timestamp 형식이라 extract를 사용, 8번은 문자열이기 때문에 cast 함수에서 text를 사용해야함.

-- 9. 구매액에서 할인 쿠폰 값을 제외한 매출 금액을 구하기

select amount-coupon as discount, amount-coalesce(coupon, 0) as df
from purchase_log_with_coupon;

-- coalesce(value, 0) : null 값이 있으면 0으로 대체

