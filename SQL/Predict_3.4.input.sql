
 -- calculate the whole race (two both needed)
DROP TABLE IF EXISTS B_PreProcess.Raw;
CREATE TABLE B_PreProcess.Raw AS
with a as (
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
select 
	dt,meters
	,h,r,t
	,wb,rw,p
	,o
	,(meters/dursec) mark --speed mark
	,cw,rww,ct,dursec
from a
;

-- calculation begin - data preprocess (Predict process) 1
DROP TABLE IF EXISTS B_PreProcess.Rand;
CREATE TABLE B_PreProcess.Rand as 
	select --潘明輝(-2)
		meter*1.0 meter,
		case when instr(馬名, '(')>=1 then (substr(馬名, 0, instr(馬名, '('))) else 馬名 end h,
		case when instr(騎師, '(')>=1 then (substr(騎師, 0, instr(騎師, '('))) else 騎師 end r,
		case when instr(練馬師, '(')>=1 then (substr(練馬師, 0, instr(練馬師, '('))) else 練馬師 end t,
		-- 馬名 h,騎師 r,練馬師 t,
		b.*,
		今季獎金*1.0 wb,
		負磅*1.0 rw,
		檔位*1.0 p
	from A_Ra.RaceCard b
	where dt=(select dt from RaceCard order by dt desc limit 1)
;

-- (Accuracy analyse) 2
select * from B_PreProcess.Raw;