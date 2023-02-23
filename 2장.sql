SELECT * FROM shop_db.member;
select * from shop_db.member where member_name = '아이유';

# 인덱스 : 없어도 관계는 없지만, 정보를 빨리 찾는데 도움을 줌, 대용량 데이터에서는 필수
# execution plan : 실행 계획, index의 사용여부에 따라 시간이 달라지는 것을 가시적으로 확인 가능

create index idx_member_name on member(member_name);

# 뷰(view) : 가상의 테이블, 바로가기와 유사함. 뷰의 실체는 select 문.

create view member_view
as
select * from member;

select * from member_view;

# 스토어드 프로시저 : SQL 안에서 프로그래밍(if, for 등)을 사용하기 위해 사용

DELIMITER //
create procedure myPro()
begin
	select * from member where member_name = '나훈아';
	select * from product where product_name = '삼김';
end //
DELIMITER ;

call myPro();

# 스토어드 프로시저, mysql 단축키 정리

use market_db; # 해당 db를 사용한다고 선언, 따로 use문을 쓰거나 db를 지정하지 않으면 sql이 해당 db에서 계속 구동

select * from member where mem_name = '블랙핑크';

select * from member where mem_number = 4;

select mem_id, mem_name
from member
where height <= 162;

select mem_name, height, mem_number
from member
where height >= 165 or mem_number > 6;

select mem_name, height, mem_number
from member
where height >= 162 and mem_number > 6;

select mem_name, height
from member 
where height between 163 and 165; # 숫자 사이의 값으로 조건을 걸때 필요

select mem_name, addr
from member
where addr in ('경기','전남','경남'); # or문 대신 사용 가능

select * from member
where mem_name like '우%'; # 우로 시작하는 말

select * from member
where mem_name like '%핑크'; # 핑크로 끝나는 말, __(언더바)를 글자 수만큼 사용해서도 조건 지정 가능


delimiter //
create procedure myFunc()
begin
select * from member where member_name = '나훈아';
select * from product where product_name = '삼김';
end //
delimiter ;	

call myFunc();

# insert, delete, update

insert into product values ('커피', 2000, '2023-02-01', 'Star', 20);
select * from product;

delete from product where product_name = '커피';
select * from product;

update product
set cost = 1200
where product_name = '삼김';

select * from product;

# where 조건절, 집계함수, order by

use market_db;

select * 
from member
where mem_name = '블랙핑크';

select *
from member 
where mem_name like '우%';

select * 
from member;

select mem_id, sum(amount) as '구매 합계'
from buy
group by mem_id
having sum(amount) >= 6;

select mem_id, mem_name, debut_date
from member
order by debut_date desc;
