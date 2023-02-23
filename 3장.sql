# insert문

use market_db;

create table hongong1 (toy_id int, toy_name char(4), age int);
insert into hongong1 values (1, '우디', 25);

insert into hongong1(toy_id, toy_name) values (2, '버즈');

insert into hongong1(toy_name, age, toy_id) values ('제시',20,3);

create table hongong2(
	toy_id int auto_increment primary key,  
    # auto_increment : column이 값울 자동으로 입력하고 싶을 떄 사용(1,2,3,..) , 사용시 pk 지정 필요
    toy_name char(4),
    age int);
    
insert into hongong2 values (null, '보핍', 25);
insert into hongong2 values (null, '슬링키', 22);
insert into hongong2 values (null, '렉스', 21);

select * from hongong2;

select last_insert_id(); # auto_increment가 어디까지 입력되었는지 확인 가능

alter table hongong2 auto_increment = 100; # auto_increment의 값을 설정하면 이후의 값은 설정한 값부터 적용됨
insert into hongong2 values (null,'재남',35);
select * from hongong2; # 3다음 100이 된 것을 확인, 이후 101, 102...

create table hongong3(
	toy_id int auto_increment primary key,
    toy_name char(4),
    age int);
    
alter table hongong3 auto_increment = 1000;

set @@auto_increment_increment=3; # auto_increment의 값에 간격을 두고싶을때 사용. ex) 3이면 1000,1003,...

insert into hongong3 values (null, '토마스', 20);
insert into hongong3 values (null, '제임스', 23);
insert into hongong3 values (null, '고든', 26);

select * from hongong3;

select count(*) from world.city; # world db안의 city table 확인

desc world.city; # table의 구조 확인 가능

select * from world.city limit 5;

create table city_popul(
	city_name char(35),
    population int);
    
insert into city_popul(
	select Name, population from world.city); # select 문의 결과를 테이블로 저장
    
select * from city_popul limit 3;

# update문

use market_db;

select * from city_popul where city_name = 'Seoul';

update city_popul
set city_name = '서울'
where city_name = 'Seoul';

# safe update mode가 활성화 되어있는 경우, 오류가 발생하고 실행이 되지 않음.
# 상단바 edit - Preferences - sql editor - safe updates 체크 해제. 설정 이후 workbench를 다시 시작해야 함.
# update문을 사용할 때 where 절을 사용하지 않으면 set에 해당하는 column 전체가 변동되니 주의 !

select * from city_popul where city_name = '서울';

update city_popul
set population = population / 10000;
# 가시성 강화를 위해 만단위로 절삭, 전체를 바꾸기 때문에 where 절이 필요없음

select * from city_popul limit 4;

# delete문

# New로 시작하는 도시 이름이 있는 열을 5개만 지워라.

delete from city_popul
where city_name like 'New%'
limit 5;

# mysql 데이터 형식







