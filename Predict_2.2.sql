

DROP TABLE IF EXISTS result1;
CREATE TABLE result1 as 
with
	Rand as (
		select --潘明輝(-2)
			case when instr(馬名, '(')>=1 then (substr(馬名, 0, instr(馬名, '('))) else 馬名 end h,
			case when instr(騎師, '(')>=1 then (substr(騎師, 0, instr(騎師, '('))) else 騎師 end r,
			case when instr(練馬師, '(')>=1 then (substr(練馬師, 0, instr(練馬師, '('))) else 練馬師 end t,
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
		(select value from Cache where `key`='wb') wbef,
		(select value from Cache where `key`='rw') rwef,
		(select value from Cache where `key`='p') pef,
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

DROP TABLE IF EXISTS result2;
CREATE TABLE result2 as 
	select 
		result1.dt,result1.raceno
		,h,r,t
		,(case when havo=0 then (ahavo) else havo end)*havm havo
		,(case when ravo=0 then (aravo) else ravo end)*ravm ravo
		,(case when tavo=0 then (atavo) else tavo end)*tavm tavo
		,(1-((wb-minwb)/(maxwb-minwb)))*wbef wb
		,(rw-minrw)/(maxrw-minrw)*rwef rw
		,1-(p-minp)/(maxp-minp)*pef p
		,havm,ravm,tavm
		,hc,rc,tc
	from result1,preventnull
	where preventnull.dt=result1.dt and result1.raceno=preventnull.raceno
;

DROP TABLE IF EXISTS result3;
CREATE TABLE result3 as 
	select 
		dt 日期,
		raceno 埸次,
		h 馬,
		havo 馬勝率,
		r 騎師,
		ravo 騎師勝率,
		t 訓練師,
		tavo 訓練師勝率,
		p 排位勝率,
		rw 馬負磅勝率, -- case when rw=0 then 0.1 else rw end
		wb 賠率勝率 -- case when wb=0 then 0.1 else wb end
	from result2
;


DROP TABLE IF EXISTS result4;
CREATE TABLE result4 as 
	select 
		*,
		((馬勝率+騎師勝率+訓練師勝率)) 單位綜合勝率,
		((賠率勝率+馬負磅勝率+排位勝率)) 臨埸比例勝率,
		((馬負磅勝率+排位勝率)) 非人為臨埸勝率
	from result3
;

DROP TABLE IF EXISTS result5;
CREATE TABLE result5 as 
select
	日期,埸次,馬,round(馬勝率,4) 馬勝率,騎師,round(騎師勝率,4) 騎師勝率,訓練師,round(訓練師勝率,4) 訓練師勝率
	,round((單位綜合勝率+非人為臨埸勝率),4) 綜合勝率
	,round(非人為臨埸勝率,4) 臨埸勝率
	,round(單位綜合勝率,4) 單位勝率
	,round(排位勝率,4) 排位勝率
	,round(馬負磅勝率,4) 馬負磅勝率
	,round((單位綜合勝率+臨埸比例勝率),4) 賠率綜合勝率
	,round(臨埸比例勝率,4) 賠率臨埸勝率
	,round(賠率勝率,4) 賠率勝率
	--,round(馬勝率,4) 馬勝率,round(騎師勝率,4) 騎師勝率,round(訓練師勝率,4) 訓練師勝率
from result4
where 埸次 in (4,5,6)
order by 日期 desc,埸次 asc,綜合勝率 desc;


DROP TABLE IF EXISTS result6;
CREATE TABLE result6 as 
select
	日期,埸次
	,馬
	,馬勝率,(ROW_NUMBER () OVER (Partition by 日期,埸次 ORDER BY 馬勝率 desc)) rank1
	,騎師
	,騎師勝率,(ROW_NUMBER () OVER (Partition by 日期,埸次 ORDER BY 騎師勝率 desc)) rank2
	,訓練師
	,訓練師勝率,(ROW_NUMBER () OVER (Partition by 日期,埸次 ORDER BY 訓練師勝率 desc)) rank3
	,綜合勝率,(ROW_NUMBER () OVER (Partition by 日期,埸次 ORDER BY 綜合勝率 desc)) rank4
	,臨埸勝率,(ROW_NUMBER () OVER (Partition by 日期,埸次 ORDER BY 臨埸勝率 desc)) rank5
	,單位勝率,(ROW_NUMBER () OVER (Partition by 日期,埸次 ORDER BY 單位勝率 desc)) rank6
	,排位勝率,(ROW_NUMBER () OVER (Partition by 日期,埸次 ORDER BY 排位勝率 desc)) rank7
	,馬負磅勝率,(ROW_NUMBER () OVER (Partition by 日期,埸次 ORDER BY 馬負磅勝率 desc)) rank8
	,賠率綜合勝率,(ROW_NUMBER () OVER (Partition by 日期,埸次 ORDER BY 賠率綜合勝率 desc)) rank9
	,賠率臨埸勝率,(ROW_NUMBER () OVER (Partition by 日期,埸次 ORDER BY 賠率臨埸勝率 desc)) rank10
	,賠率勝率,(ROW_NUMBER () OVER (Partition by 日期,埸次 ORDER BY 賠率勝率 desc)) rank11
from result5
order by 日期 desc,埸次 asc,綜合勝率 desc;
commit;