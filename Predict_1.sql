with
latestDate as (
select dt from RaceCard order by dt desc limit 1
),
latestCom as (
select b.* from latestDate a,RaceCard b
where a.dt=b.dt
)
select * from latestCom
;