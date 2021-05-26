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
			,meters meters
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
DROP TABLE IF EXISTS h; CREATE TABLE h as select h,max(mark) mam,avg(mark) avo,min(mark) mim,meters,count(*) c from NorRaw group by h,meters;
DROP TABLE IF EXISTS r; CREATE TABLE r as select r,max(mark) mam,avg(mark) avo,min(mark) mim,meters,count(*) c from NorRaw group by r,meters;
DROP TABLE IF EXISTS t; CREATE TABLE t as select t,max(mark) mam,avg(mark) avo,min(mark) mim,meters,count(*) c from NorRaw group by t,meters;

--上名率
DROP TABLE IF EXISTS h_t3; CREATE TABLE h_t3 AS 
WITH 
a as (select h,meters,count(*) a from NorRaw group by h,meters)
,c as (select h,meters,count(*) c from NorRaw where o <=4 group by h,meters)
select a.h,a.meters,c*1.0/a a from a,c where a.h=c.h and a.meters=c.meters
;
DROP TABLE IF EXISTS r_t3; CREATE TABLE r_t3 AS 
WITH 
a as (select r,meters,count(*) a from NorRaw group by r,meters)
,c as (select r,meters,count(*) c from NorRaw where o <=4 group by r,meters)
select a.r,a.meters,c*1.0/a a from a,c where a.r=c.r and a.meters=c.meters
;
DROP TABLE IF EXISTS t_t3; CREATE TABLE t_t3 AS 
WITH 
a as (select t,meters,count(*) a from NorRaw group by t,meters)
,c as (select t,meters,count(*) c from NorRaw where o <=4 group by t,meters)
select a.t,a.meters,c*1.0/a a from a,c where a.t=c.t and a.meters=c.meters
;

-- rate effectiveness
DROP TABLE IF EXISTS Cache;
CREATE TABLE Cache as 
with
effectivenessRates as (
	select
		meters,
		(
			with ana as ( select h ke1, meters ke2,(max(mark)-min(mark)) dif, count(*) c from NorRaw a where a.meters=b.meters group by ke1,ke2 ) select ((min(dif)+avg(dif)+max(dif))/3) ef from ana where c>1
		) havm, (
			with ana as ( select r ke1, meters ke2,(max(mark)-min(mark)) dif, count(*) c from NorRaw a where a.meters=b.meters group by ke1,ke2 ) select ((min(dif)+avg(dif)+max(dif))/3) ef from ana where c>1
		) ravm, (
			with ana as ( select t ke1, meters ke2,(max(mark)-min(mark)) dif, count(*) c from NorRaw a where a.meters=b.meters group by ke1,ke2 ) select ((min(dif)+avg(dif)+max(dif))/3) ef from ana where c>1
		) tavm, (
			with ana as ( select h ke1, meters ke2,(max(mark)-min(mark)) dif, count(*) c from NorRaw a where o<=3 and a.meters=b.meters group by ke1,ke2 ) select ((min(dif)+avg(dif)+max(dif))/3) ef from ana where c>1
		) h3t, (
			with ana as ( select r ke1, meters ke2,(max(mark)-min(mark)) dif, count(*) c from NorRaw a where o<=3 and a.meters=b.meters group by ke1,ke2 ) select ((min(dif)+avg(dif)+max(dif))/3) ef from ana where c>1
		) r3t, (
			with ana as ( select t ke1, meters ke2,(max(mark)-min(mark)) dif, count(*) c from NorRaw a where o<=3 and a.meters=b.meters group by ke1,ke2 ) select ((min(dif)+avg(dif)+max(dif))/3) ef from ana where c>1
		) t3t, (
			with ana as ( select wb ke1,(max(mark)-min(mark)) dif, count(*) c from NorRaw a where a.meters=b.meters group by ke1 ) select ((min(dif)+avg(dif)+max(dif))/3) ef from ana where c>1
		) wb, (
			with ana as ( select rw ke1,(max(mark)-min(mark)) dif, count(*) c from NorRaw a where a.meters=b.meters group by ke1 ) select ((min(dif)+avg(dif)+max(dif))/3) ef from ana where c>1
		) rw, (
			with ana as ( select rww ke1,(max(mark)-min(mark)) dif, count(*) c from NorRaw a where a.meters=b.meters group by ke1 ) select ((min(dif)+avg(dif)+max(dif))/3) ef from ana where c>1
		) rww, (
			with ana as ( select p ke1,(max(mark)-min(mark)) dif, count(*) c from NorRaw a where a.meters=b.meters group by ke1 ) select ((min(dif)+avg(dif)+max(dif))/3) ef from ana where c>1
		) p
	from NorRaw b group by meters
)
,sum as (
	SELECT 
		meters,( -- real count of data factor
		havm+ravm+tavm
		+h3t+r3t+t3t
		--+wb
		+rw
		--+rww
		+p
	) sum from effectivenessRates
)
,sum1 as (
	select 
		effectivenessRates.meters,
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
	where effectivenessRates.meters=sum.meters
)
,sum2 as (
	SELECT 
		meters,
		(
			havm+ravm+tavm
			+h3t+r3t+t3t
			--+wb
			+rw
			--+rww
			+p
		) sum,
		(h3t+r3t+t3t) sum1
	from sum1
)
,sum3 as (
	select 
		sum1.meters,
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
		,(h3t/sum1) h3t1
		,(r3t/sum1) r3t1
		,(t3t/sum1) t3t1
	from sum1,sum2
	where sum1.meters=sum2.meters
)
select * from sum3
;

-- calculation begin - data preprocess
DROP TABLE IF EXISTS result1;
CREATE TABLE result1 as 
with
	Rand as (
		select --潘明輝(-2)
			meter*1.0,
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
		meter,
		raceno+0 raceno,
		Rand.h,Rand.r,Rand.t,
		IFNULL((select avo from h where h.h like '%'||Rand.h||'%' and meters=meter),0) havo,
		IFNULL((select avo from r where r.r like '%'||Rand.r||'%' and meters=meter),0) ravo,
		IFNULL((select avo from t where t.t like '%'||Rand.t||'%' and meters=meter),0) tavo,
		wb*1.0 wb,
		rw*1.0 rw,
		p*1.0 p
		,ifnull((select a from h_t3 where h_t3.h=Rand.h and h_t3.meters=Rand.meter),
			ifnull((select a from h_t3 where h_t3.h=Rand.h and h_t3.meters<Rand.meter order by h_t3.meters desc limit 1),
				ifnull((select a from h_t3 where h_t3.h=Rand.h and h_t3.meters>Rand.meter order by h_t3.meters asc limit 1),
					NULL
				)
			)
		) h3t
		,ifnull((select a from r_t3 where r_t3.r=Rand.r and r_t3.meters=Rand.meter),
			ifnull((select a from r_t3 where r_t3.r=Rand.r and r_t3.meters<Rand.meter order by r_t3.meters desc limit 1),
				ifnull((select a from r_t3 where r_t3.r=Rand.r and r_t3.meters>Rand.meter order by r_t3.meters asc limit 1),
					NULL
				)
			)
		) r3t
		,ifnull((select a from t_t3 where t_t3.t=Rand.t and t_t3.meters=Rand.meter),
			ifnull((select a from t_t3 where t_t3.t=Rand.h and t_t3.meters<Rand.meter order by t_t3.meters desc limit 1),
				ifnull((select a from t_t3 where t_t3.t=Rand.t and t_t3.meters>Rand.meter order by t_t3.meters asc limit 1),
					NULL
				)
			)
		) t3t
	from 
		Rand
	group by Rand.dt,Rand.h
;

-- Prevent no records
DROP TABLE IF EXISTS preventnull;
CREATE TABLE preventnull as 
	select 
		dt,raceno,meter
		,(select avg(b.havo) from result1 b where b.havo>0 and a.meter=b.meter) ahavo
		,(select avg(b.ravo) from result1 b where b.havo>0 and a.meter=b.meter) aravo
		,(select avg(b.tavo) from result1 b where b.havo>0 and a.meter=b.meter) atavo
		,(select avg(a) from h_t3 where a>0 and h_t3.meters=a.meter) ht3
		,(select avg(a) from r_t3 where a>0 and r_t3.meters=a.meter) rt3
		,(select avg(a) from t_t3 where a>0 and t_t3.meters=a.meter) tt3
	from result1 a
	group by dt,raceno,meter
;

-- Prepare for normalization
DROP TABLE IF EXISTS preNor;
CREATE TABLE preNor as 
	select 
		dt,raceno
		,max(havo) maxhavo,min(havo) minhavo
		,max(ravo) maxravo,min(ravo) minravo
		,max(tavo) maxtavo,min(tavo) mintavo
		,max(h3t) maxh3t,min(h3t) minh3t
		,max(r3t) maxr3t,min(r3t) minr3t
		,max(t3t) maxt3t,min(t3t) mint3t
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
		result1.dt
		,result1.meter
		,result1.raceno
		,h,r,t
		,(((case when havo=0 then (ahavo) else havo end)-minhavo)/(maxhavo-minhavo)) havo
		,(((case when ravo=0 then (aravo) else ravo end)-minravo)/(maxravo-minravo)) ravo
		,(((case when tavo=0 then (atavo) else tavo end)-mintavo)/(maxtavo-mintavo)) tavo
		,((ifnull(h3t,ht3)-minh3t)/(maxh3t-minh3t)) h3t
		,((ifnull(r3t,rt3)-minr3t)/(maxr3t-minr3t)) r3t
		,((ifnull(t3t,tt3)-mint3t)/(maxt3t-mint3t)) t3t
		,(1-((wb-minwb)/(maxwb-minwb))) wb
		,(rw-minrw)/(maxrw-minrw) rw
		,1-(p-minp)/(maxp-minp) p
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
		meter 路程,
		h 馬,
		r 騎師,
		t 訓練師,
		result2.havo*Cache.havm 馬勝率,
		result2.ravo*Cache.ravm 騎師勝率,
		result2.tavo*Cache.tavm 訓練師勝率,
		result2.h3t*Cache.h3t 馬上名率,
		result2.r3t*Cache.r3t 騎師上名率,
		result2.t3t*Cache.t3t 訓練師上名率,
		result2.h3t*Cache.h3t1 馬上名率1,
		result2.r3t*Cache.r3t1 騎師上名率1,
		result2.t3t*Cache.t3t1 訓練師上名率1,
		result2.p*Cache.p 排位勝率,
		result2.rw*Cache.rw 馬負磅勝率 -- case when rw=0 then 0.1 else rw end
		,result2.wb*Cache.wb 賠率勝率 -- case when wb=0 then 0.1 else wb end
	from result2,Cache
	where result2.meter*1.0=Cache.meters*1.0
;

-- second integrate various kinds of rate
DROP TABLE IF EXISTS result4;
CREATE TABLE result4 as 
select
	日期,埸次,
	路程,
	馬,
	騎師,
	訓練師,
	(馬勝率+馬上名率+騎師勝率+騎師上名率+訓練師勝率+訓練師勝率+訓練師上名率+排位勝率+馬負磅勝率) 綜合勝率,
	(馬上名率1+騎師上名率1+訓練師上名率1) 上名率
from result3
-- where 埸次 in (4,5,6)
order by 日期 desc,埸次 asc,綜合勝率 desc;

-- ranking sorting and indication
DROP TABLE IF EXISTS result5;
CREATE TABLE result5 as 
select
	日期,埸次
	,路程
	,馬
	,騎師
	,訓練師
	,綜合勝率,(ROW_NUMBER () OVER (Partition by 日期,埸次 ORDER BY 綜合勝率 desc)) 綜合勝率排名
	,上名率,(ROW_NUMBER () OVER (Partition by 日期,埸次 ORDER BY 上名率 desc)) 上名率排名
from result4
order by 日期 desc,埸次 asc,綜合勝率 desc;

DROP TABLE IF EXISTS result6;

commit;