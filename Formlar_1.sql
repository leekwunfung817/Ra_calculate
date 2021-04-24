
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
,mp as ( -- bigger value, less effective
	select 
	(
		select 
			avg(case when m<0 then m*-1 else m end)
		from (
			select 
				h.avo-NorRaw.mark,3 m 
			from h,NorRaw
			where h.h=NorRaw.h
			group by h.h
		)
	) havm
	,(
		select 
			avg(case when m<0 then m*-1 else m end)
		from (
			select 
				r.avo-NorRaw.mark,3 m 
			from r,NorRaw
			where r.r=NorRaw.r
			group by r.r
		)
	) ravm
	,(
		select 
			avg(case when m<0 then m*-1 else m end)
		from (
			select 
				t.avo-NorRaw.mark m 
			from t,NorRaw
			where t.t=NorRaw.t
			group by t.t
		)
	) tavm
)
,Rand as ( -- future data as history data
	select * from NorRaw 
	where dt=(
		SELECT dt from NorRaw 
		group by dt
		ORDER BY RANDOM()
		limit 1
	)
)
-- select * from Rand;
select 
	Rand.dt,
	Rand.o,
	((select avo from h where Rand.h=h.h)/havm)*
	((select avo from r where Rand.r=r.r)/ravm)*
	((select avo from t where Rand.t=t.t)/tavm) gm
from 
	Rand,mp
order by dt,gm desc
;
