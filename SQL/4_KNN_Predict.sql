DROP TABLE IF EXISTS B_PreProcess.KNNPredict; -- calculate the whole race
CREATE TABLE B_PreProcess.KNNPredict AS
with 
raw as (
		SELECT
			--馬名,
			ifnull((select avm from h where h.h like '%'||馬名||'%'),0) havo,
			ifnull((select avm from r where r.r like '%'||騎師||'%'),0) ravo,
			ifnull((select avm from t where t.t like '%'||練馬師||'%'),0) tavo,
			dt
			,負磅*1.0 rw
			,排位體重*1.0 cw
			,(排位體重-負磅)*1.0 rww
			,今季獎金*1.0 wb
			,檔位*1.0 p
		from RaceCard b
		where 1=1
		and dt=(select dt from RaceCard order by dt desc limit 1)
		and raceno in (4,5,6)
)
,raw1 as (
	SELECT
		dt,
		rw,cw,rww,wb,p,
		havo,ravo,tavo
	from raw
)
,RaceVar as (
	select 
		--dt
		--,min(o)*1.0 mino, max(o)*1.0 maxo, count(*) uc -- unit count
		min(rww) minrww, max(rww) maxrww -- rider with waering
		,min(cw) mincw,max(cw) maxcw
		,min(rw) minrw,max(rw) maxrw
		,min(wb) minwb,max(wb) maxwb
		,min(p) minp,max(p) maxp
		,min(havo) minhavo,max(havo) maxhavo
		,min(ravo) minravo,max(ravo) maxravo
		,min(tavo) mintavo,max(tavo) maxtavo
	from raw1 a
)
,raw3 as (
	select
		(havo-minhavo)/(maxhavo-minhavo) h
		,(ravo-minravo)/(maxravo-minravo) r
		,(tavo-mintavo)/(maxtavo-mintavo) t
		,maxtavo,mintavo
		,(rw-minrw)/(maxrw-minrw) rw
		,(cw-mincw)/(maxcw-mincw) cw
		,(rww-minrww)/(maxrww-minrww) rww
		,(wb-minwb)/(maxwb-minwb) wb
		,(p-minp)/(maxp-minp) p
		,havo,ravo,tavo
	from raw1 b,RaceVar a
)
select 
	--t,maxtavo,mintavo,
	'['||rw||','||cw||','||rww||','||wb||','||p||','||h||','||r||','||t||'],' train
from raw3
;
commit;