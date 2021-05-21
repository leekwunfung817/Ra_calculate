-- Normalise history data
DROP TABLE IF EXISTS NorRaw; -- calculate the whole race
CREATE TABLE NorRaw AS
with 
raw as (
		SELECT 
			LocalResults.dt,
			CAST( REPLACE(名次,' ','') AS INTEGER ) o,
			case when instr(馬名, '(')>=1 then (substr(馬名, 0, instr(馬名, '('))) else 馬名 end h,
			case when instr(騎師, '(')>=1 then (substr(騎師, 0, instr(騎師, '('))) else 騎師 end r,
			case when instr(練馬師, '(')>=1 then (substr(練馬師, 0, instr(練馬師, '('))) else 練馬師 end t,
			實際負磅*1.0 rw,-- real weight (just horse)
			排位體重*1.0 cw,-- comparitive weight (horse with rider and wearing)
			(排位體重-實際負磅)*1.0 rww,-- rider with weight
			完成時間 ct -- complete time
			,((substr(完成時間,0,instr(完成時間,':'))*60)+(substr(完成時間, instr(完成時間, ':')+1,length(完成時間)-1)))*1.0 dursec
			,meters*1.0 meters
			,獨贏賠率*1.0 wb -- win bounis
			,檔位*1.0 p
		from LocalResults, LocalResultsComInfo
		where o!=0 and LocalResults.dt=LocalResultsComInfo.dt
)
,RaceVar as (
	select 
		dt
		,min(o)*1.0 mino, max(o)*1.0 maxo, count(*) uc -- unit count
		,min(rww) minrww, max(rww) maxrww -- rider with waering
		,min(cw) mincw,max(cw) maxcw
		,min(rw) minrw,max(rw) maxrw
		,min(wb) minwb,max(wb) maxwb
		,min(dursec) mindursec,max(dursec) maxdursec
		,min(p) minp,max(p) maxp
	from raw a
	group by a.dt
)
select 
	a.dt
	,o
	,h,r,t
	,(b.meters/dursec) mark --speed mark
	,(rw-minrw)/(maxrw-minrw) rw
	,(ROW_NUMBER () OVER (Partition by a.dt ORDER BY rw desc)) rwrank
	,(cw-mincw)/(maxcw-mincw) cw
	,(ROW_NUMBER () OVER (Partition by a.dt ORDER BY cw desc)) cwrank
	,(rww-minrww)/(maxrww-minrww) rww
	,(ROW_NUMBER () OVER (Partition by a.dt ORDER BY rww desc)) rwwrank
	,(wb-minwb)/(maxwb-minwb) wb
	,(ROW_NUMBER () OVER (Partition by a.dt ORDER BY wb asc)) wbrank
	,(dursec-mindursec)/(maxdursec-mindursec) ndursec
	,(p-minp)/(maxp-minp) p
	,(ROW_NUMBER () OVER (Partition by a.dt ORDER BY p asc)) prank
	,b.meters,dursec
from raw b,RaceVar a
where a.dt=b.dt
order by b.dt desc,o asc
;


-- unit data cache
DROP TABLE IF EXISTS h; CREATE TABLE h as select h,avg(mark) avo,count(*) c from NorRaw group by h;
DROP TABLE IF EXISTS r; CREATE TABLE r as select r,avg(mark) avo,count(*) c from NorRaw group by r;
DROP TABLE IF EXISTS t; CREATE TABLE t as select t,avg(mark) avo,count(*) c from NorRaw group by t;

--上名率
DROP TABLE IF EXISTS h_t3; CREATE TABLE h_t3 AS 
WITH 
a as (select h,count(*) a from NorRaw group by h)
,c as (select h,count(*) c from NorRaw where o >=3 group by h)
select a.h,c*1.0/a a from a,c where a.h=c.h
;
DROP TABLE IF EXISTS r_t3; CREATE TABLE r_t3 AS 
WITH 
a as (select r,count(*) a from NorRaw group by r)
,c as (select r,count(*) c from NorRaw where o >=3 group by r)
select a.r,c*1.0/a a from a,c where a.r=c.r
;
DROP TABLE IF EXISTS t_t3; CREATE TABLE t_t3 AS 
WITH 
a as (select t,count(*) a from NorRaw group by t)
,c as (select t,count(*) c from NorRaw where o >=3 group by t)
select a.t,c*1.0/a a from a,c where a.t=c.t
;

-- rate effectiveness
with
effectivenessRates as (
	select
		(
			with ana as ( select h ke1, meters ke2,(max(mark)-min(mark)) dif, count(*) c from NorRaw group by ke1,ke2 ) select ((min(dif)+avg(dif)+max(dif))/3) ef from ana where c>1
		) havm, (
			with ana as ( select r ke1, meters ke2,(max(mark)-min(mark)) dif, count(*) c from NorRaw group by ke1,ke2 ) select ((min(dif)+avg(dif)+max(dif))/3) ef from ana where c>1
		) ravm, (
			with ana as ( select t ke1, meters ke2,(max(mark)-min(mark)) dif, count(*) c from NorRaw group by ke1,ke2 ) select ((min(dif)+avg(dif)+max(dif))/3) ef from ana where c>1
		) tavm, (
			with ana as ( select h ke1, meters ke2,(max(mark)-min(mark)) dif, count(*) c from NorRaw where o<=3 group by ke1,ke2 ) select ((min(dif)+avg(dif)+max(dif))/3) ef from ana where c>1
		) h3t, (
			with ana as ( select r ke1, meters ke2,(max(mark)-min(mark)) dif, count(*) c from NorRaw where o<=3 group by ke1,ke2 ) select ((min(dif)+avg(dif)+max(dif))/3) ef from ana where c>1
		) r3t, (
			with ana as ( select t ke1, meters ke2,(max(mark)-min(mark)) dif, count(*) c from NorRaw where o<=3 group by ke1,ke2 ) select ((min(dif)+avg(dif)+max(dif))/3) ef from ana where c>1
		) t3t, (
			with ana as ( select wb ke1,(max(mark)-min(mark)) dif, count(*) c from NorRaw group by ke1 ) select ((min(dif)+avg(dif)+max(dif))/3) ef from ana where c>1
		) wb, (
			with ana as ( select rw ke1,(max(mark)-min(mark)) dif, count(*) c from NorRaw group by ke1 ) select ((min(dif)+avg(dif)+max(dif))/3) ef from ana where c>1
		) rw, (
			with ana as ( select rww ke1,(max(mark)-min(mark)) dif, count(*) c from NorRaw group by ke1 ) select ((min(dif)+avg(dif)+max(dif))/3) ef from ana where c>1
		) rww, (
			with ana as ( select p ke1,(max(mark)-min(mark)) dif, count(*) c from NorRaw group by ke1 ) select ((min(dif)+avg(dif)+max(dif))/3) ef from ana where c>1
		) p
)
,sum as (
	SELECT ( -- real count of data factor
		havm+ravm+tavm
		+h3t+r3t+t3t
		+wb+rw+rww+p
	) sum from effectivenessRates
)
,sum1 as (
	select 
		(sum-havm/sum) havm
		,(sum-ravm/sum) ravm
		,(sum-tavm/sum) tavm 
		,(sum-h3t/sum) h3t
		,(sum-r3t/sum) r3t
		,(sum-t3t/sum) t3t 
		,(sum-wb/sum) wb
		,(sum-rw/sum) rw
		,(sum-rww/sum) rww
		,(sum-p/sum) p
	from effectivenessRates,sum
)
,sum2 as (
	SELECT (
		havm+ravm+tavm
		+h3t+r3t+t3t
		+wb+rw+rww+p
	) sum from sum1
)
,sum3 as (
	select 
		(havm/sum) havm
		,(ravm/sum) ravm
		,(tavm/sum) tavm 
		,(h3t/sum) h3t
		,(r3t/sum) r3t
		,(t3t/sum) t3t 
		,(wb/sum) wb
		,(rw/sum) rw
		,(rww/sum) rww
		,(p/sum) p
	from sum1,sum2
)
select * from sum3
;
	
delete from Cache where `key`='wb'; insert into Cache select 'wb' ke,(with  
	L as (select dt,h,r,t,mark,wb ana_val  FROM NorRaw),
	L1 as (SELECT dt,h,r,t,mark,round(ana_val,2) ana_val FROM L where ana_val is not null),
	L2 as (select avg(mark) avgmark from L1 group by ana_val order by avgmark asc) 
	select (max(avgmark)-min(avgmark)) 影響率 from L2) val;
delete from Cache where `key`='rw'; insert into Cache select 'rw' ke,(with  
	L as (select dt,h,r,t,mark,rw ana_val  FROM NorRaw),
	L1 as (SELECT dt,h,r,t,mark,round(ana_val,2) ana_val FROM L where ana_val is not null),
	L2 as (select avg(mark) avgmark from L1 group by ana_val order by avgmark asc) 
	select (max(avgmark)-min(avgmark)) 影響率 from L2) val;
delete from Cache where `key`='cw'; insert into Cache select 'cw' ke,(with  
	L as (select dt,h,r,t,mark,cw ana_val  FROM NorRaw),
	L1 as (SELECT dt,h,r,t,mark,round(ana_val,2) ana_val FROM L where ana_val is not null),
	L2 as (select avg(mark) avgmark from L1 group by ana_val order by avgmark asc) 
	select (max(avgmark)-min(avgmark)) 影響率 from L2) val;
delete from Cache where `key`='rww'; insert into Cache select 'rww' ke,(with  
	L as (select dt,h,r,t,mark,rww ana_val  FROM NorRaw),
	L1 as (SELECT dt,h,r,t,mark,round(ana_val,2) ana_val FROM L where ana_val is not null),
	L2 as (select avg(mark) avgmark from L1 group by ana_val order by avgmark asc) 
	select (max(avgmark)-min(avgmark)) 影響率 from L2) val;
delete from Cache where `key`='p';insert into Cache select 'p' ke,(with  
	L as (select dt,h,r,t,mark,p ana_val  FROM NorRaw),
	L1 as (SELECT dt,h,r,t,mark,round(ana_val,2) ana_val FROM L where ana_val is not null),
	L2 as (select avg(mark) avgmark from L1 group by ana_val order by avgmark asc) 
	select (max(avgmark)-min(avgmark)) 影響率 from L2) val;

-- calculation begin - data preprocess
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

-- Prevent no records
DROP TABLE IF EXISTS preventnull;
CREATE TABLE preventnull as 
	select 
		dt,raceno
		,(select avg(b.havo) from result1 b where b.havo>0) ahavo
		,(select avg(b.ravo) from result1 b where b.havo>0) aravo
		,(select avg(b.tavo) from result1 b where b.havo>0) atavo
	from result1 a
	group by dt,raceno
;

-- Prepare for normalization
DROP TABLE IF EXISTS preNor;
CREATE TABLE preNor as 
	select 
		dt,raceno
		,max(wb) maxwb,min(wb) minwb
		,max(rw) maxrw,min(rw) minrw
		,max(p) maxp, min(p) minp
	from result1
	group by dt,raceno
;

-- normalization
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
	from result1,preventnull,preNor
	where 1=1
	and preventnull.dt=result1.dt 
	and result1.raceno=preventnull.raceno
	and preNor.dt=result1.dt 
	and result1.raceno=preNor.raceno
	
;

-- naming and translation
DROP TABLE IF EXISTS result3;
CREATE TABLE result3 as 
	select 
		dt 日期,
		raceno 埸次,
		h 馬,
		havo 馬勝率,
		(select c from h_t3 where h_t3.h=result2.h) 馬上名率,
		r 騎師,
		ravo 騎師勝率,
		(select c from h_t3 where h_t3.h=result2.h) 騎師上名率,
		t 訓練師,
		tavo 訓練師勝率,
		(select c from h_t3 where h_t3.h=result2.h) 訓練師上名率,
		p 排位勝率,
		rw 馬負磅勝率, -- case when rw=0 then 0.1 else rw end
		wb 賠率勝率 -- case when wb=0 then 0.1 else wb end
	from result2
;

-- first integrate various kinds of rate
DROP TABLE IF EXISTS result4;
CREATE TABLE result4 as 
	select 
		*,
		((馬勝率+騎師勝率+訓練師勝率)) 單位綜合勝率,
		((賠率勝率+馬負磅勝率+排位勝率)) 臨埸比例勝率,
		((馬負磅勝率+排位勝率)) 非人為臨埸勝率
	from result3
;

-- second integrate various kinds of rate
DROP TABLE IF EXISTS result5;
CREATE TABLE result5 as 
select
	日期,埸次,
	馬,
	round(馬勝率,4) 馬勝率,馬上名率,--馬上Q率,
	騎師,
	round(騎師勝率,4) 騎師勝率,騎師上名率,--騎師上Q率,
	訓練師,
	round(訓練師勝率,4) 訓練師勝率,訓練師上名率--,訓練師上Q率
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
-- where 埸次 in (4,5,6)
order by 日期 desc,埸次 asc,綜合勝率 desc;

-- ranking sorting and indication
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
	,馬上名率,(ROW_NUMBER () OVER (Partition by 日期,埸次 ORDER BY 馬上名率 desc)) rank1_1
	,騎師上名率,(ROW_NUMBER () OVER (Partition by 日期,埸次 ORDER BY 騎師上名率 desc)) rank2_1
	,訓練師上名率,(ROW_NUMBER () OVER (Partition by 日期,埸次 ORDER BY 訓練師上名率 desc)) rank3_1
	--,馬上Q率,(ROW_NUMBER () OVER (Partition by 日期,埸次 ORDER BY 馬上Q率 desc)) rank1_2
	--,騎師上Q率,(ROW_NUMBER () OVER (Partition by 日期,埸次 ORDER BY 騎師上Q率 desc)) rank2_2
	--,訓練師上Q率,(ROW_NUMBER () OVER (Partition by 日期,埸次 ORDER BY 訓練師上Q率 desc)) rank3_2
from result5
order by 日期 desc,埸次 asc,綜合勝率 desc;
commit;