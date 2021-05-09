

DROP TABLE IF EXISTS result1;
CREATE TABLE result1 as 
with
	Rand as (
		select 
			馬名 h,
			騎師 r,
			練馬師 t,
			b.*,
			今季獎金 wb,
			負磅 rw,
			檔位 p
		from RaceCard b
		where dt=(select dt from RaceCard order by dt desc limit 1)
	)
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
		IFNULL((select c from t where t.t like '%'||Rand.t||'%'),0) tc,
		wb*1.0 wb,
		rw*1.0 rw,
		p*1.0 p
	from 
		Rand
	group by Rand.dt,Rand.h
;

DROP TABLE IF EXISTS preventnull;
CREATE TABLE preventnull as 
	select 
		dt,raceno
		,avg(havo) ahavo,avg(ravo) aravo,avg(tavo) atavo
		,max(wb) maxwb,min(wb) minwb
		,max(rw) maxrw,min(rw) minrw
		,max(p) maxp, min(p) minp
	from result1
	group by dt,raceno
;

with
result2 as (
	select 
		result1.dt,result1.raceno
		,h,r,t
		,(case when havo=0 then (ahavo) else havo end) havo
		,(case when ravo=0 then (aravo) else ravo end) ravo
		,(case when tavo=0 then (atavo) else tavo end) tavo
		,(1-((wb-minwb)/(maxwb-minwb))) wb
		,(rw-minrw)/(maxrw-minrw) rw
		,1-(p-minp)/(maxp-minp) p
		,havm,ravm,tavm
		,hc,rc,tc
	from result1,preventnull
	where preventnull.dt=result1.dt and result1.raceno=preventnull.raceno
)
,result3 as (
select 
	dt 日期,
	raceno 埸次,
	h 馬,r 騎師,t 訓練師,
	round(p,3) 排位勝率,
	round(case when rw=0 then 0.1 else rw end,4) 馬負磅勝率,
	round(case when wb=0 then 0.1 else wb end,4) 賠率勝率,
	round(havo*havm,4) 馬勝率,
	round(ravo*ravm,4) 騎師勝率,
	round(tavo*tavm,4) 訓練師勝率
from result2
)
,result4 as (
select 
		*,
		round(馬勝率+騎師勝率+訓練師勝率,4) 排名比例勝率_加,
		round(馬勝率*騎師勝率*訓練師勝率,4) 排名比例勝率_乘
	from result3
)
select
	*,
	round(排名比例勝率_加+馬負磅勝率+排位勝率,4) 非人為綜合勝率_加,
	round(排名比例勝率_加+賠率勝率+馬負磅勝率+排位勝率,4) 綜合勝率_加,
	round(排名比例勝率_乘*賠率勝率*馬負磅勝率*排位勝率,4) 綜合勝率_乘
from result4
order by 日期 desc,埸次 asc,非人為綜合勝率_加 desc,綜合勝率_加 desc,綜合勝率_乘 desc
;

commit;