DROP TABLE IF EXISTS NorRaw; -- calculate the whole race
CREATE TABLE NorRaw AS
with 
raw as (
		SELECT 
			CAST(
				REPLACE(名次,' ','') 
			AS INTEGER) o,
			馬名 h,騎師 r,練馬師 t,
			實際負磅*1.0 rw,-- real weight (just horse)
			排位體重*1.0 cw,-- comparitive weight (horse with rider and wearing)
			(排位體重-實際負磅)*1.0 rww,-- rider with weight
			完成時間 ct -- complete time
			,((substr(完成時間,0,instr(完成時間,':'))*60)+(substr(完成時間, instr(完成時間, ':')+1,length(完成時間)-1)))*1.0 dursec
			,meters*1.0 meters
			,獨贏賠率*1.0 wb -- win bounis
			,檔位*1.0 p
			,LocalResults.dt
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
	--,speed mark
	,(b.meters/dursec) mark
	--,(b.meters/dursec) speed
	,(rw-minrw)/(maxrw-minrw) rw
	,(cw-mincw)/(maxcw-mincw) cw
	,(rww-minrww)/(maxrww-minrww) rww
	,(wb-minwb)/(maxwb-minwb) wb
	,(dursec-mindursec)/(maxdursec-mindursec) ndursec
	,(p-minp)/(maxp-minp) p
	,b.meters,dursec
from raw b,RaceVar a
where a.dt=b.dt
;
select * from NorRaw;
commit;
