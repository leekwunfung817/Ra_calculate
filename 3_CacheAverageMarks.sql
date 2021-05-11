
delete from Cache where `key`='havm';
insert into Cache
select 
	'havm' ke,
	1-avg(case when m<0 then m*-1 else m end) val
from (
	select 
		(h.avo-NorRaw.mark) m
	from h,NorRaw
	where h.h=NorRaw.h
	group by h.h
);

delete from Cache where `key`='ravm';
insert into Cache
select 
	'ravm' ke,
	1-avg(case when m<0 then m*-1 else m end) val
from (
	select 
		(r.avo-NorRaw.mark) m 
	from r,NorRaw
	where r.r=NorRaw.r
	group by r.r
);

delete from Cache where `key`='tavm';
insert into Cache
select 
	'tavm' ke,
	1-avg(case when m<0 then m*-1 else m end) val
from (
	select 
		(t.avo-NorRaw.mark) m 
	from t,NorRaw
	where t.t=NorRaw.t
	group by t.t
);

delete from Cache where `key`='wb';
insert into Cache select 'wb' ke,(with  L as (select dt,h,r,t,mark,wb ana_val  FROM NorRaw),L1 as (SELECT dt,h,r,t,mark,round(ana_val,2) ana_val FROM L where ana_val is not null),L2 as (select avg(mark) avgmark from L1 group by ana_val order by avgmark asc) select (max(avgmark)-min(avgmark)) 影響率 from L2) val;
delete from Cache where `key`='rw';
insert into Cache select 'rw' ke,(with  L as (select dt,h,r,t,mark,rw ana_val  FROM NorRaw),L1 as (SELECT dt,h,r,t,mark,round(ana_val,2) ana_val FROM L where ana_val is not null),L2 as (select avg(mark) avgmark from L1 group by ana_val order by avgmark asc) select (max(avgmark)-min(avgmark)) 影響率 from L2) val;
delete from Cache where `key`='cw';
insert into Cache select 'cw' ke,(with  L as (select dt,h,r,t,mark,cw ana_val  FROM NorRaw),L1 as (SELECT dt,h,r,t,mark,round(ana_val,2) ana_val FROM L where ana_val is not null),L2 as (select avg(mark) avgmark from L1 group by ana_val order by avgmark asc) select (max(avgmark)-min(avgmark)) 影響率 from L2) val;
delete from Cache where `key`='rww';
insert into Cache select 'rww' ke,(with  L as (select dt,h,r,t,mark,rww ana_val  FROM NorRaw),L1 as (SELECT dt,h,r,t,mark,round(ana_val,2) ana_val FROM L where ana_val is not null),L2 as (select avg(mark) avgmark from L1 group by ana_val order by avgmark asc) select (max(avgmark)-min(avgmark)) 影響率 from L2) val;
delete from Cache where `key`='p';
insert into Cache select 'p' ke,(with  L as (select dt,h,r,t,mark,p ana_val  FROM NorRaw),L1 as (SELECT dt,h,r,t,mark,round(ana_val,2) ana_val FROM L where ana_val is not null),L2 as (select avg(mark) avgmark from L1 group by ana_val order by avgmark asc) select (max(avgmark)-min(avgmark)) 影響率 from L2) val;

commit;
