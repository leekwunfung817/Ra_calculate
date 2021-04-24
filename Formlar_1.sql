
with
RandFromLast100LocalResults as (
	select dt from (
		SELECT dt from LocalResults 
		order by dt desc 
		limit 1000
	)
	order by RANDOM() limit 1
)
,RandLast1000Com as (
	select * from LocalResults 
	where dt=(
		select dt from RandFromLast100LocalResults
	)
)
,RandPredictHistory as (
	select 
		a.名次,CAST(a.名次 AS INTEGER) o,a.馬名 h,a.騎師 r,a.練馬師 t,a.dt,
		(
			SELECT avg(o)||'_'||count(*) oc from 
			(
				SELECT 
					CAST(名次 AS INTEGER) o,
					馬名 n
				FROM LocalResults 
				where 1=1 
				and dt!=a.dt
				and 馬名=a.馬名
			)
		) aa,
		(
			SELECT avg(o)||'_'||count(*) oc from 
			(
				SELECT 
					CAST(名次 AS INTEGER) o,
					騎師 n
				FROM LocalResults 
				where 1=1 
				and dt!=a.dt
				and 騎師=a.騎師
			)
		) bb,
		(
			SELECT avg(o)||'_'||count(*) oc from 
			(
				SELECT 
					CAST(名次 AS INTEGER) o,
					練馬師 n
				FROM LocalResults 
				where dt!=a.dt
				and 練馬師=a.練馬師
			)
		) cc
	from 
		RandLast1000Com a
	order by CAST(a.名次 AS INTEGER) asc
),
Predicted as (
	select * 
	from RandPredictHistory
)
select * from Predicted;
