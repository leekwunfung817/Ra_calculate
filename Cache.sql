delete from Cache where `key`='havm';
insert into Cache
with 
raw as (
		SELECT 
			CAST(
				REPLACE(名次,' ','') 
			AS INTEGER) o,
			馬名 h,騎師 r,練馬師 t,
			dt
		from LocalResults 
		where o!=0
)
,RaceVar as (
	select dt,min(o) mino, max(o) maxo, count(*) uc -- unit count
	from raw a
	group by a.dt
)
,NorRaw as (
	select ((maxo-o)+1) mark,*
	from RaceVar a,raw b
	where a.dt=b.dt
)
,h as (
	select h,round(avg(mark),3) avo,count(*) c from NorRaw
	group by h
)
,r as (
	select r,round(avg(mark),3) avo,count(*) c from NorRaw
	group by r
)
,t as (
	select t,round(avg(mark),3) avo,count(*) c from NorRaw
	group by t
)
select 
	'havm' ke,
	avg(case when m<0 then m*-1 else m end) val
from (
	select 
		(h.avo-NorRaw.mark) m
	from h,NorRaw
	where h.h=NorRaw.h
	group by h.h
);
commit;















delete from Cache where `key`='ravm';
insert into Cache
with 
raw as (
		SELECT 
			CAST(
				REPLACE(名次,' ','') 
			AS INTEGER) o,
			馬名 h,騎師 r,練馬師 t,
			dt
		from LocalResults 
		where o!=0
)
,RaceVar as (
	select dt,min(o) mino, max(o) maxo, count(*) uc -- unit count
	from raw a
	group by a.dt
)
,NorRaw as (
	select ((maxo-o)+1) mark,*
	from RaceVar a,raw b
	where a.dt=b.dt
)
,h as (
	select h,round(avg(mark),3) avo,count(*) c from NorRaw
	group by h
)
,r as (
	select r,round(avg(mark),3) avo,count(*) c from NorRaw
	group by r
)
,t as (
	select t,round(avg(mark),3) avo,count(*) c from NorRaw
	group by t
)
select 
	'ravm' ke,
	avg(case when m<0 then m*-1 else m end) val
from (
	select 
		(r.avo-NorRaw.mark) m 
	from r,NorRaw
	where r.r=NorRaw.r
	group by r.r
);
commit;










delete from Cache where `key`='tavm';
insert into Cache
with 
raw as (
		SELECT 
			CAST(
				REPLACE(名次,' ','') 
			AS INTEGER) o,
			馬名 h,騎師 r,練馬師 t,
			dt
		from LocalResults 
		where o!=0
)
,RaceVar as (
	select dt,min(o) mino, max(o) maxo, count(*) uc -- unit count
	from raw a
	group by a.dt
)
,NorRaw as (
	select ((maxo-o)+1) mark,*
	from RaceVar a,raw b
	where a.dt=b.dt
)
,h as (
	select h,round(avg(mark),3) avo,count(*) c from NorRaw
	group by h
)
,r as (
	select r,round(avg(mark),3) avo,count(*) c from NorRaw
	group by r
)
,t as (
	select t,round(avg(mark),3) avo,count(*) c from NorRaw
	group by t
)
select 
	'tavm' ke,
	avg(case when m<0 then m*-1 else m end) val
from (
	select 
		(t.avo-NorRaw.mark) m 
	from t,NorRaw
	where t.t=NorRaw.t
	group by t.t
);
commit;







DROP TABLE h;
CREATE TABLE h as
with 
raw as (
		SELECT 
			CAST(
				REPLACE(名次,' ','') 
			AS INTEGER) o,
			馬名 h,騎師 r,練馬師 t,
			dt
		from LocalResults 
		where o!=0
)
,RaceVar as (
	select dt,min(o) mino, max(o) maxo, count(*) uc -- unit count
	from raw a
	group by a.dt
)
,NorRaw as (
	select ((maxo-o)+1) mark,*
	from RaceVar a,raw b
	where a.dt=b.dt
)
select h,round(avg(mark),3) avo,count(*) c from NorRaw
group by h
;




DROP TABLE r;
CREATE TABLE r as
with 
raw as (
		SELECT 
			CAST(
				REPLACE(名次,' ','') 
			AS INTEGER) o,
			馬名 h,騎師 r,練馬師 t,
			dt
		from LocalResults 
		where o!=0
)
,RaceVar as (
	select dt,min(o) mino, max(o) maxo, count(*) uc -- unit count
	from raw a
	group by a.dt
)
,NorRaw as (
	select ((maxo-o)+1) mark,*
	from RaceVar a,raw b
	where a.dt=b.dt
)
select r,round(avg(mark),3) avo,count(*) c from NorRaw
group by r
;




DROP TABLE t;
CREATE TABLE t as
with 
raw as (
		SELECT 
			CAST(
				REPLACE(名次,' ','') 
			AS INTEGER) o,
			馬名 h,騎師 r,練馬師 t,
			dt
		from LocalResults 
		where o!=0
)
,RaceVar as (
	select dt,min(o) mino, max(o) maxo, count(*) uc -- unit count
	from raw a
	group by a.dt
)
,NorRaw as (
	select ((maxo-o)+1) mark,*
	from RaceVar a,raw b
	where a.dt=b.dt
)
select t,round(avg(mark),3) avo,count(*) c from NorRaw
group by t
;


