

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
,result2 as (
select 
	dt 日期,
	raceno 埸次,
	h 馬,r 騎師,t 訓練師,
	(havo/havm)*(ravo/ravm)*(tavo/tavm) 比例勝率,
	havo*ravo*tavo 平算勝率,
	hc+rc+tc 準確率信心,
	-- havo*ravo*tavo,
	(havo/havm) 馬勝率,
	(ravo/ravm) 騎師勝率,
	(tavo/tavm) 訓練師勝率,
	hc 馬準確率信心,rc 騎師準確率信心,tc 訓練師準確率信心
from result1 
)
select * from result2
order by 日期 desc,埸次 asc,比例勝率 desc
;
