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
		from LocalResults, LocalResultsComInfo
		where LocalResults.dt=LocalResultsComInfo.dt
)
,raw1 as (
	SELECT
		dt,
		--o,
		--h,r,t,
		rw,cw,rww,ct,wb,p,
		dursec,meters,
		meters/dursec speed
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
	from raw1 a
)
select
	(speed-minspeed)/(maxspeed-minspeed) mark
	,(-minspeed)/(maxspeed-minspeed) h
	,(rw-minrw)/(maxrw-minrw) rw
	,(cw-mincw)/(maxcw-mincw) cw
	,(rww-minrww)/(maxrww-minrww) rww
	,(wb-minwb)/(maxwb-minwb) wb
	--,(dursec-mindursec)/(maxdursec-mindursec) dursec
	,(p-minp)/(maxp-minp) p
from raw1 b,RaceVar a
;
--select * from KNNNorRaw;



select '['||rw||','||cw||','||rww||','||wb||','||p||'],' train,'['||mark||'],' result from KNNNorRaw;

commit;