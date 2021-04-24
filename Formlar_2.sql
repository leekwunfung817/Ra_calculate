
with 
raw as (
		SELECT 
			dt,名次 oo,
			CAST(
				REPLACE(名次,' ','') 
			AS INTEGER) o,
			馬名 h,騎師 r,練馬師 t
		from LocalResults 
		order by dt desc 
		limit 1000
)
,raw2 as (
	SELECT * FROM raw 
	where o!=0
)
,Rand as (
	select * from raw2 where dt=(
		SELECT dt from raw2 
		group by dt
		order by dt desc 
		limit 1
	)
)
,RaceVar as (
	select min(o) mino, max(o) maxo, count(*) uc -- unit count
	from Rand 
	group by dt
)
,h as (
	select h,avg(o) avo,count(*) c from raw2
	group by h
	order by avo asc
)
,r as (
	select r,avg(o) avo,count(*) c from raw2
	group by r
	order by avo asc
)
,t as (
	select t,avg(o) avo,count(*) c from raw2
	group by t
	order by avo asc
)
,mp as (
	select 
	(
		select avg(m) havm from (
			select h.h,avg(avo- ((maxo-o)/(o-mino)) ) m from h,raw2
			where h.h=raw2.h
			group by h.h
			order by m desc
		)
	) havm,
	(
		select avg(m) from (
			select r.r,avg(avo- ((maxo-o)/(o-mino)) ) m from r,raw2
			where r.r=raw2.r
			group by r.r
			order by m desc
		)
	) ravm,
	(
		select avg(m) havm from (
			select t.t,avg(avo- ((maxo-o)/(o-mino)) ) m from t,raw2,RaceVar
			where t.t=raw2.t and RaceVar.dt=raw2.dt
			group by t.t
			order by m desc
		)
	) tavm
)
select Rand.dt,Rand.o,(h.avo/havm)*(r.avo/ravm)*(t.avo/tavm) gm 
from Rand,h,r,t,mp
where Rand.h=h.h and Rand.r=r.r and Rand.t=t.t
order by o
;
