DROP TABLE IF EXISTS KNNNorRaw; -- calculate the whole race
CREATE TABLE KNNNorRaw AS
with 
raw as (
		SELECT 
			LocalResults.dt
			,實際負磅*1.0 rw
			,排位體重*1.0 cw
			,(排位體重-實際負磅)*1.0 rww
			,完成時間 ct
			,((substr(完成時間,0,instr(完成時間,':'))*60)+(substr(完成時間, instr(完成時間, ':')+1,length(完成時間)-1)))*1.0 dursec
			,meters*1.0 meters
			,獨贏賠率*1.0 wb
			,檔位*1.0 p
			,IFNULL(h.avo,0) havo
			,IFNULL(r.avo,0) ravo
			,IFNULL(t.avo,1) tavo
		from LocalResults, LocalResultsComInfo,h,r,t
		where LocalResults.dt=LocalResultsComInfo.dt
		and h.h=馬名 and r.r=騎師 and t.t=練馬師
)
,raw1 as (
	SELECT
		dt,
		--o,
		--h,r,t,
		rw,cw,rww,ct,wb,p,
		dursec,meters,
		meters/dursec speed,
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
		,min(dursec) mindursec,max(dursec) maxdursec
		,min(p) minp,max(p) maxp
		,min(speed) minspeed,max(speed) maxspeed
		,min(havo) minhavo,max(havo) maxhavo
		,min(ravo) minravo,max(ravo) maxravo
		,min(tavo) mintavo,max(tavo) maxtavo
	from raw1 a
)
,raw3 as (
	select
		(speed-minspeed)/(maxspeed-minspeed) mark
		,(havo-minhavo)/(maxhavo-minhavo) h
		,(ravo-minravo)/(maxravo-minravo) r
		,(tavo-mintavo)/(maxtavo-mintavo) t
		,maxtavo,mintavo
		,(rw-minrw)/(maxrw-minrw) rw
		,(cw-mincw)/(maxcw-mincw) cw
		,(rww-minrww)/(maxrww-minrww) rww
		,(wb-minwb)/(maxwb-minwb) wb
		--,(dursec-mindursec)/(maxdursec-mindursec) dursec
		,(p-minp)/(maxp-minp) p
		,havo,ravo,tavo
	from raw1 b,RaceVar a
)
select 
	--t,maxtavo,mintavo,
	'['||rw||','||cw||','||rww||','||wb||','||p||','||h||','||r||','||t||'],' train,
	''||mark||',' result 
from raw3
where result is not NULL and train is not NULL;
;
--select * from KNNNorRaw;





commit;