
-- cw avg speed
DROP TABLE IF EXISTS B_PreProcess.cw; CREATE TABLE B_PreProcess.cw as 
WITH
a as (
	select 
		cw,
		meters,
		mark m 
	from Raw 
	where cw is not null and cw > 0
)
,avg as (
	select 
		cw
		,meters
		,avg(m) avm
		,count(*) c 
	from a 
	group by cw,meters
)
,std as (
	select 
		a.cw,a.meters
		,avg.avm
		,sum(abs(avm-m))/count(*) dif
		,c
	from a,avg 
	where a.cw=avg.cw and a.meters=avg.meters 
	group by a.cw,a.meters
)
select * from std
;

-- wb avg speed
DROP TABLE IF EXISTS B_PreProcess.wb; CREATE TABLE B_PreProcess.wb as 
WITH
a as (
	select 
		wb,
		meters,
		mark m 
	from Raw 
	where wb is not null and wb > 0
)
,avg as (
	select 
		wb
		,meters
		,avg(m) avm
		,count(*) c 
	from a 
	group by wb,meters
)
,std as (
	select 
		a.wb,a.meters
		,avg.avm
		,sum(abs(avm-m))/count(*) dif
		,c
	from a,avg 
	where a.wb=avg.wb and a.meters=avg.meters 
	group by a.wb,a.meters
)
select * from std
;

-- rw avg speed
DROP TABLE IF EXISTS B_PreProcess.rw; CREATE TABLE B_PreProcess.rw as 
WITH
a as (
	select 
		rw,
		meters,
		mark m 
	from Raw 
	where rw is not null and rw > 0
)
,avg as (
	select 
		rw
		,meters
		,avg(m) avm
		,count(*) c 
	from a 
	group by rw,meters
)
,std as (
	select 
		a.rw,a.meters
		,avg.avm
		,sum(abs(avm-m))/count(*) dif
		,c
	from a,avg 
	where a.rw=avg.rw and a.meters=avg.meters 
	group by a.rw,a.meters
)
select * from std
;

-- rww avg speed
DROP TABLE IF EXISTS B_PreProcess.rww; CREATE TABLE B_PreProcess.rww as 
WITH
a as (
	select 
		rww,
		meters,
		mark m 
	from Raw 
	where rww is not null and rww > 0
)
,avg as (
	select 
		rww
		,meters
		,avg(m) avm
		,count(*) c 
	from a 
	group by rww,meters
)
,std as (
	select 
		a.rww,a.meters
		,avg.avm
		,sum(abs(avm-m))/count(*) dif
		,c
	from a,avg 
	where a.rww=avg.rww and a.meters=avg.meters 
	group by a.rww,a.meters
)
select * from std
;

-- p avg speed
DROP TABLE IF EXISTS B_PreProcess.p; CREATE TABLE B_PreProcess.p as 
WITH
a as (
	select 
		p,
		meters,
		mark m 
	from Raw 
	where p is not null and p > 0
)
,avg as (
	select 
		p
		,meters
		,avg(m) avm
		,count(*) c 
	from a 
	group by p,meters
)
,std as (
	select 
		a.p,a.meters
		,avg.avm
		,sum(abs(avm-m))/count(*) dif
		,c
	from a,avg 
	where a.p=avg.p and a.meters=avg.meters 
	group by a.p,a.meters
)
select * from std
;

-- unit data cache
DROP TABLE IF EXISTS B_PreProcess.h; CREATE TABLE B_PreProcess.h as 
WITH
a as (
	select 
		h,
		meters,
		mark m 
	from Raw 
	where h is not null
)
,avg as (
	select 
		h
		,meters
		,avg(m) avm
		,count(*) c 
	from a 
	group by h,meters
)
,std as (
	select 
		a.h,a.meters
		,avg.avm
		,sum(abs(avm-m))/count(*) dif
		,c
	from a,avg 
	where a.h=avg.h and a.meters=avg.meters 
	group by a.h,a.meters
)
select * from std
;

DROP TABLE IF EXISTS B_PreProcess.r; CREATE TABLE B_PreProcess.r as 
WITH
a as (
	select 
		r,
		meters,
		mark m 
	from Raw 
	where r is not null
)
,avg as (
	select 
		r
		,meters
		,avg(m) avm
		,count(*) c 
	from a 
	group by r,meters
)
,std as (
	select 
		a.r,a.meters
		,avg.avm
		,sum(abs(avm-m))/count(*) dif
		,c
	from a,avg 
	where a.r=avg.r and a.meters=avg.meters 
	group by a.r,a.meters
)
select * from std
;

DROP TABLE IF EXISTS B_PreProcess.t; CREATE TABLE B_PreProcess.t as 
WITH
a as (
	select 
		t,
		meters,
		mark m 
	from Raw 
	where t is not null
)
,avg as (
	select 
		t
		,meters
		,avg(m) avm
		,count(*) c 
	from a 
	group by t,meters
)
,std as (
	select 
		a.t,a.meters
		,avg.avm
		,sum(abs(avm-m))/count(*) dif
		,c
	from a,avg 
	where a.t=avg.t and a.meters=avg.meters 
	group by a.t,a.meters
)
select * from std
;

--上名率
DROP TABLE IF EXISTS B_PreProcess.h_t3; CREATE TABLE B_PreProcess.h_t3 AS 
WITH 
a as (select h,meters,count(*) a from Raw group by h,meters)
,c as (select h,meters,count(*) c from Raw where o <=4 group by h,meters)
select a.h,a.meters,c*1.0/a a from a,c where a.h=c.h and a.meters=c.meters
;
DROP TABLE IF EXISTS B_PreProcess.r_t3; CREATE TABLE B_PreProcess.r_t3 AS 
WITH 
a as (select r,meters,count(*) a from Raw group by r,meters)
,c as (select r,meters,count(*) c from Raw where o <=4 group by r,meters)
select a.r,a.meters,c*1.0/a a from a,c where a.r=c.r and a.meters=c.meters
;
DROP TABLE IF EXISTS B_PreProcess.t_t3; CREATE TABLE B_PreProcess.t_t3 AS 
WITH 
a as (select t,meters,count(*) a from Raw group by t,meters)
,c as (select t,meters,count(*) c from Raw where o <=4 group by t,meters)
select a.t,a.meters,c*1.0/a a from a,c where a.t=c.t and a.meters=c.meters
;


-- Prevent no records
DROP TABLE IF EXISTS D_Formula.preventnull;
CREATE TABLE D_Formula.preventnull as 
	select 
		dt,raceno,meter
		,(select avg(b.avm) from B_PreProcess.h b where b.avm>0 and a.meter=b.meters) ahavo
		,(select avg(b.avm) from B_PreProcess.r b where b.avm>0 and a.meter=b.meters) aravo
		,(select avg(b.avm) from B_PreProcess.t b where b.avm>0 and a.meter=b.meters) atavo
		,(select avg(b.avm) from B_PreProcess.wb b where b.avm>0) wb
		,(select avg(b.avm) from B_PreProcess.rw b where b.avm>0 and a.meter=b.meters) rw
		,(select avg(b.avm) from B_PreProcess.rww b where b.avm>0 and a.meter=b.meters) rww
		,(select avg(b.avm) from B_PreProcess.p b where b.avm>0 and a.meter=b.meters) p
		
		,(select avg(b.dif) from B_PreProcess.h b where b.avm>0 and a.meter=b.meters) ahavo_e
		,(select avg(b.dif) from B_PreProcess.r b where b.avm>0 and a.meter=b.meters) aravo_e
		,(select avg(b.dif) from B_PreProcess.t b where b.avm>0 and a.meter=b.meters) atavo_e
		,(select avg(b.dif) from B_PreProcess.wb b where b.avm>0) wb_e
		,(select avg(b.dif) from B_PreProcess.rw b where b.avm>0 and a.meter=b.meters) rw_e
		,(select avg(b.dif) from B_PreProcess.rww b where b.avm>0 and a.meter=b.meters) rww_e
		,(select avg(b.dif) from B_PreProcess.p b where b.avm>0 and a.meter=b.meters) p_e
	from Rand a
	group by dt,raceno,meter
;

-- calculation begin - data preprocess
DROP TABLE IF EXISTS D_Formula.result1;
CREATE TABLE D_Formula.result1 as 
select 
	Rand.dt,
	Rand.meter,
	(Rand.raceno+0)*1.0 raceno
	,Rand.h,Rand.r,Rand.t
	,ifnull((select avm from B_PreProcess.h where h.h like '%'||Rand.h||'%' and h.meters<=Rand.meter order by h.meters desc limit 1),
		ifnull((select avm from B_PreProcess.h where h.h like '%'||Rand.h||'%' and h.meters>Rand.meter order by h.meters asc limit 1),
			ahavo
		)
	) havo
	,ifnull((select avm from B_PreProcess.r where r.r like '%'||Rand.r||'%' and r.meters<=B_PreProcess.Rand.meter order by r.meters desc limit 1),
		ifnull((select avm from B_PreProcess.r where r.r like '%'||Rand.r||'%' and r.meters>B_PreProcess.Rand.meter order by r.meters asc limit 1),
			aravo
		)
	) ravo
	,ifnull((select avm from B_PreProcess.t where t.t like '%'||Rand.t||'%' and t.meters<=Rand.meter order by t.meters desc limit 1),
		ifnull((select avm from B_PreProcess.t where t.t like '%'||Rand.t||'%' and t.meters>Rand.meter order by t.meters asc limit 1),
			atavo
		)
	) tavo
	,ifnull((select avm from B_PreProcess.wb where wb.wb<=Rand.wb and wb.meters<=Rand.meter order by wb.meters desc limit 1),
		ifnull((select avm from B_PreProcess.wb where wb.wb>Rand.wb and wb.meters>Rand.meter order by wb.meters asc limit 1),
			preventnull.wb
		)
	) wb
	,ifnull((select avm from B_PreProcess.rw where rw.rw=Rand.rw and rw.meters<=Rand.meter order by rw.meters desc limit 1),
		ifnull((select avm from B_PreProcess.rw where rw.rw=Rand.rw and rw.meters>Rand.meter order by rw.meters asc limit 1),
			preventnull.rw
		)
	) rw
	,ifnull((select avm from B_PreProcess.p where p.p=Rand.p and p.meters<=Rand.meter order by p.meters desc limit 1),
		ifnull((select avm from B_PreProcess.p where p.p=Rand.p and p.meters>Rand.meter order by p.meters asc limit 1),
			preventnull.p
		)
	) p
	
	
	,1-ifnull((select dif from B_PreProcess.h where h.h like '%'||Rand.h||'%' and h.meters<=Rand.meter order by h.meters desc limit 1),
		ifnull((select dif from B_PreProcess.h where h.h like '%'||Rand.h||'%' and h.meters>Rand.meter order by h.meters asc limit 1),
			ahavo_e
		)
	) havo_e
	,1-ifnull((select dif from B_PreProcess.r where r.r like '%'||Rand.r||'%' and r.meters<=Rand.meter order by r.meters desc limit 1),
		ifnull((select dif from B_PreProcess.r where r.r like '%'||Rand.r||'%' and r.meters>Rand.meter order by r.meters asc limit 1),
			aravo_e
		)
	) ravo_e
	,1-ifnull((select dif from B_PreProcess.t where t.t like '%'||Rand.t||'%' and t.meters<=Rand.meter order by t.meters desc limit 1),
		ifnull((select dif from B_PreProcess.t where t.t like '%'||Rand.t||'%' and t.meters>Rand.meter order by t.meters asc limit 1),
			atavo_e
		)
	) tavo_e
	,1-ifnull((select dif from B_PreProcess.wb where wb.wb>=Rand.wb and wb.meters<=Rand.meter order by wb.meters desc limit 1),
		ifnull((select dif from B_PreProcess.wb where wb.wb<=Rand.wb and wb.meters>Rand.meter order by wb.meters asc limit 1),
			wb_e
		)
	) wb_e
	,1-ifnull((select dif from B_PreProcess.rw where rw.rw=Rand.rw and rw.meters<=Rand.meter order by rw.meters desc limit 1),
		ifnull((select dif from B_PreProcess.rw where rw.rw=Rand.rw and rw.meters>Rand.meter order by rw.meters asc limit 1),
			rw_e
		)
	) rw_e
	,1-ifnull((select dif from B_PreProcess.p where p.p=Rand.p and p.meters<=Rand.meter order by p.meters desc limit 1),
		ifnull((select dif from B_PreProcess.p where p.p=Rand.p and p.meters>Rand.meter order by p.meters asc limit 1),
			p_e
		)
	) p_e
	
	
	
	,ifnull((select a from B_PreProcess.h_t3 where h_t3.h=Rand.h and h_t3.meters<=Rand.meter order by h_t3.meters desc limit 1),
		ifnull((select a from B_PreProcess.h_t3 where h_t3.h=Rand.h and h_t3.meters>Rand.meter order by h_t3.meters asc limit 1),
			0
		)
	) h3t
	,ifnull((select a from B_PreProcess.r_t3 where r_t3.r=Rand.r and r_t3.meters<=Rand.meter order by r_t3.meters desc limit 1),
		ifnull((select a from B_PreProcess.r_t3 where r_t3.r=Rand.r and r_t3.meters>Rand.meter order by r_t3.meters asc limit 1),
			0
		)
	) r3t
	,ifnull((select a from B_PreProcess.t_t3 where t_t3.t=Rand.h and t_t3.meters<=Rand.meter order by t_t3.meters desc limit 1),
		ifnull((select a from B_PreProcess.t_t3 where t_t3.t=Rand.t and t_t3.meters>Rand.meter order by t_t3.meters asc limit 1),
			0
		)
	) t3t
from 
	B_PreProcess.Rand,D_Formula.preventnull
where Rand.dt=preventnull.dt and Rand.raceno=preventnull.raceno
group by Rand.dt,Rand.raceno,Rand.h
;

-- normalization
DROP TABLE IF EXISTS D_Formula.result2;
CREATE TABLE D_Formula.result2 as 
with
a as (
	select 
		*
		,(havo_e+ravo_e+tavo_e) sum_t3_e
		,(havo_e+ravo_e+tavo_e
		--+wb_e
		+rw_e+p_e) sum_e
	from D_Formula.result1
)
select 
	*
	,h3t/sum_t3_e havo_t3_er
	,r3t/sum_t3_e ravo_t3_er
	,t3t/sum_t3_e tavo_t3_er
	,havo_e/sum_e havo_er
	,ravo_e/sum_e ravo_er
	,tavo_e/sum_e tavo_er
	--,wb_e/sum_e wb_er
	,rw_e/sum_e rw_er
	,p_e/sum_e p_er
from a
;

-- naming and translation
DROP TABLE IF EXISTS D_Formula.result3;
CREATE TABLE D_Formula.result3 as 
	select 
		dt 日期,
		raceno 埸次,
		meter 路程,
		h 馬,
		r 騎師,
		t 訓練師,
		result2.havo*havo_er 馬勝率,
		result2.ravo*ravo_er 騎師勝率,
		result2.tavo*tavo_er 訓練師勝率,
		-- result2.p*p_er 排位勝率,
		result2.rw*rw_er 馬負磅勝率, -- case when rw=0 then 0.1 else rw end
		-- result2.wb*wb_er 賠率勝率, -- case when wb=0 then 0.1 else wb end
		result2.h3t*havo_t3_er 馬上名率,
		result2.r3t*ravo_t3_er 騎師上名率,
		result2.t3t*tavo_t3_er 訓練師上名率
	from D_Formula.result2
;

-- second integrate various kinds of rate
DROP TABLE IF EXISTS D_Formula.result4;
CREATE TABLE D_Formula.result4 as 
select
	日期,埸次,
	路程,
	馬,
	騎師,
	訓練師,
	(馬勝率+騎師勝率+訓練師勝率
	-- +排位勝率
	+馬負磅勝率) 綜合勝率,
	(馬上名率+騎師上名率+訓練師上名率) 上名率
from D_Formula.result3
-- where 埸次 in (4,5,6)
order by 日期 desc,埸次 asc,綜合勝率 desc;

-- ranking sorting and indication
DROP TABLE IF EXISTS D_Formula.result5F3_4;
CREATE TABLE D_Formula.result5F3_4 as 
select
	日期,埸次
	,路程
	,馬
	,騎師
	,訓練師
	,round(綜合勝率,4) 綜合勝率,(ROW_NUMBER () OVER (Partition by 日期,埸次 ORDER BY 綜合勝率 desc)) 綜合勝率排名
	,round(上名率,4) 上名率,(ROW_NUMBER () OVER (Partition by 日期,埸次 ORDER BY 上名率 desc)) 上名率排名
	,round(dif,2) dif
from D_Formula.result4,(
	with 
		hh as (select meters,avg(1-dif) dif from h group by meters),
		rr as (select meters,avg(1-dif) dif from r group by meters),
		tt as (select meters,avg(1-dif) dif from t group by meters),
		r1 as (select hh.meters,(hh.dif+rr.dif+tt.dif)/3 dif,hh.dif h,rr.dif r,tt.dif t from hh,rr,tt where hh.meters=rr.meters and tt.meters=rr.meters),
		h1 as (select max(dif) maxdif,min(dif) mindif from r1),
		rr1 as (select meters,1-(dif-mindif)/(maxdif-mindif) wr from r1,h1)
		select * from r1
) e_diff
where e_diff.meters=路程
order by 日期 desc,埸次 asc,綜合勝率 desc;

DROP TABLE IF EXISTS D_Formula.result6F3_4;
CREATE TABLE D_Formula.result6F3_4 as 
select * from D_Formula.result5F3_4 where dif in (
	select dif from D_Formula.result5F3_4 group by 日期,埸次 order by dif desc limit 2
)
;

commit;