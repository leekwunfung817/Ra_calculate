
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
				(h.avo-NorRaw.mark) m 
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
				(r.avo-NorRaw.mark) m 
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
				(t.avo-NorRaw.mark) m 
			from t,NorRaw
			where t.t=NorRaw.t
			group by t.t
		)
	) tavm
)
,Rand as ( -- future data as history data
	select * from NorRaw 
	where dt = (
		SELECT dt from NorRaw 
		group by dt
		ORDER BY RANDOM()
		limit 1
	)
)
,result1 as (
	-- select * from Rand;
	select 
		Rand.dt,
		-- Rand.o,
		Rand.h,Rand.r,Rand.t,
		(select avo from h where Rand.h=h.h) havo,
		(select avo from r where Rand.r=r.r) ravo,
		(select avo from t where Rand.t=t.t) tavo,
		havm,ravm,tavm,
		(select c from h where Rand.h=h.h) hc,
		(select c from r where Rand.r=r.r) rc,
		(select c from t where Rand.t=t.t) tc
	from 
		Rand,mp
	group by dt,h
)
select 
	dt,
	--o,
	h,r,t,
	havo*ravo*tavo gm,
	(havo/havm)*(ravo/ravm)*(tavo/tavm) egm,
	hc+rc+tc confident
from result1 
order by dt desc ,gm desc
-- ,result2 as ( select (havo/havm)*(ravo/ravm)*(tavo/tavm) gm from result1 order by dt,gm desc );
