with
latestDate as (
select dt from RaceCard order by dt desc limit 1
),
latestCom as (
	select 
		馬名 h,
		騎師 r,
		練馬師 t,
		b.*
	from latestDate a,RaceCard b
	where a.dt=b.dt
)
select 
	*
from latestCom
;