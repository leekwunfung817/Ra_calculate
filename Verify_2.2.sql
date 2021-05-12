

DROP TABLE IF EXISTS verify1;
CREATE TABLE verify1 as 
with
	Rand as (
		select 
			REPLACE(名次,' ','')*1 o,
			(substr(dt, instr(dt, '_')+1, length(dt)-1)) raceno,
			馬名 h,
			騎師 r,
			練馬師 t,
			b.*,
			獨贏賠率 wb,
			實際負磅 rw,
			檔位 p
		from LocalResults b
		--where dt=(select dt from LocalResults order by dt desc limit 1)
	)
	select 
		o,
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
	from verify1
	group by dt,raceno
;

DROP TABLE IF EXISTS verify2;
CREATE TABLE verify2 as 
	select 
		o
		,verify1.dt,verify1.raceno
		,h,r,t
		,(case when havo=0 then (ahavo) else havo end)*havm havo
		,(case when ravo=0 then (aravo) else ravo end)*ravm ravo
		,(case when tavo=0 then (atavo) else tavo end)*tavm tavo
		,(1-((wb-minwb)/(maxwb-minwb)))*wbef wb
		,(rw-minrw)/(maxrw-minrw)*rwef rw
		,1-(p-minp)/(maxp-minp)*pef p
		,havm,ravm,tavm
		,hc,rc,tc
	from verify1,preventnull
	where preventnull.dt=verify1.dt and verify1.raceno=preventnull.raceno
;

DROP TABLE IF EXISTS verify3;
CREATE TABLE verify3 as 
	select 
		o,
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
	from verify2
;


DROP TABLE IF EXISTS verify4;
CREATE TABLE verify4 as 
	select 
		*,
		((馬勝率+騎師勝率+訓練師勝率)) 單位綜合勝率,
		((賠率勝率+馬負磅勝率+排位勝率)) 臨埸比例勝率,
		((馬負磅勝率+排位勝率)) 非人為臨埸勝率
	from verify3
;

DROP TABLE IF EXISTS verify5;
CREATE TABLE verify5 as 
select
	o,日期,埸次,馬,round(馬勝率,4) 馬勝率,騎師,round(騎師勝率,4) 騎師勝率,訓練師,round(訓練師勝率,4) 訓練師勝率
	,round((單位綜合勝率+非人為臨埸勝率),4) 綜合勝率
	,round(非人為臨埸勝率,4) 臨埸勝率
	,round(單位綜合勝率,4) 單位勝率
	,round(排位勝率,4) 排位勝率
	,round(馬負磅勝率,4) 馬負磅勝率
	,round((單位綜合勝率+臨埸比例勝率),4) 賠率綜合勝率
	,round(臨埸比例勝率,4) 賠率臨埸勝率
	,round(賠率勝率,4) 賠率勝率
	--,round(馬勝率,4) 馬勝率,round(騎師勝率,4) 騎師勝率,round(訓練師勝率,4) 訓練師勝率
from verify4
--where 埸次 in (4,5,6)
order by 日期 desc,埸次 asc,綜合勝率 desc;


DROP TABLE IF EXISTS verify6;
CREATE TABLE verify6 as 
select
	o,日期,埸次
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
from verify5
order by 日期 desc,埸次 asc,綜合勝率 desc;

DROP TABLE IF EXISTS verify7;
CREATE TABLE verify7 as 
with
dtList as (select count(*) dtc from verify1 group by dt),
accuracy as (
	select 
		(select (count(*)*1.0)/(dtc) from verify6 where o<=topnum and rank1<=topnum) 馬勝率,
		(select (count(*)*1.0)/(dtc) from verify6 where o<=topnum and rank2<=topnum) 騎師勝率,
		(select (count(*)*1.0)/(dtc) from verify6 where o<=topnum and rank3<=topnum) 訓練師勝率,
		(select (count(*)*1.0)/(dtc) from verify6 where o<=topnum and rank4<=topnum) 綜合勝率,
		(select (count(*)*1.0)/(dtc) from verify6 where o<=topnum and rank5<=topnum) 臨埸勝率,
		(select (count(*)*1.0)/(dtc) from verify6 where o<=topnum and rank6<=topnum) 單位勝率,
		(select (count(*)*1.0)/(dtc) from verify6 where o<=topnum and rank7<=topnum) 排位勝率,
		(select (count(*)*1.0)/(dtc) from verify6 where o<=topnum and rank8<=topnum) 馬負磅勝率,
		(select (count(*)*1.0)/(dtc) from verify6 where o<=topnum and rank9<=topnum) 賠率綜合勝率,
		(select (count(*)*1.0)/(dtc) from verify6 where o<=topnum and rank10<=topnum) 賠率臨埸勝率,
		(select (count(*)*1.0)/(dtc) from verify6 where o<=topnum and rank11<=topnum) 賠率勝率
	from (select count(*)*4 dtc,4 topnum from dtList)
)
select * from accuracy
;
DROP TABLE IF EXISTS verify8;
CREATE TABLE verify8 as 
select * from (
select '馬勝率' name,馬勝率 accuracy from verify7
union select '騎師勝率',騎師勝率 from verify7
union select '訓練師勝率',訓練師勝率 from verify7
union select '綜合勝率',綜合勝率 from verify7
union select '臨埸勝率',臨埸勝率 from verify7
union select '單位勝率',單位勝率 from verify7
union select '排位勝率',排位勝率 from verify7
union select '馬負磅勝率',馬負磅勝率 from verify7
union select '賠率綜合勝率',賠率綜合勝率 from verify7
union select '賠率臨埸勝率',賠率臨埸勝率 from verify7
union select '賠率勝率',賠率勝率 from verify7
) order by accuracy desc
;

commit;