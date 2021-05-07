

with
Rand as (
	select 
		馬名 h,
		騎師 r,
		練馬師 t,
		b.*
	from RaceCard b
	where dt=(select dt from RaceCard order by dt desc limit 1)
)
,result1 as (
	select 
		Rand.dt,
		raceno+0 raceno,
		Rand.h,Rand.r,Rand.t,
		IFNULL((select avo from h where h.h like '%'||Rand.h||'%'),0) havo,
		IFNULL((select avo from r where r.r like '%'||Rand.r||'%'),0) ravo,
		IFNULL((select avo from t where t.t like '%'||Rand.t||'%'),0) tavo,
		(select value from Cache where `key`='havm') havm,
		(select value from Cache where `key`='ravm') ravm,
		(select value from Cache where `key`='tavm') tavm,
		IFNULL((select c from h where h.h like '%'||Rand.h||'%'),0) hc,
		IFNULL((select c from r where r.r like '%'||Rand.r||'%'),0) rc,
		IFNULL((select c from t where t.t like '%'||Rand.t||'%'),0) tc
	from 
		Rand
	group by Rand.dt,Rand.h
)
select 
	dt,
	raceno,
	h,r,t,
	havo*ravo*tavo gm,
	(havo/havm)*(ravo/ravm)*(tavo/tavm) egm,
	hc+rc+tc confident
from result1 
order by dt desc,raceno asc,gm desc
;
