drop view RandLast100LocalResults;
create view RandLast100LocalResults as
select * from (
SELECT dt from LocalResults order by dt desc limit 1000
)
order by RANDOM() limit 1
;

drop view RandLast1000Com;
create view RandLast1000Com as
select * from LocalResults where dt=(select dt from RandLast100LocalResults);
select * from RandLast1000Com;


drop view RandPredictHistory;
create view RandPredictHistory as
select 
	CAST(a.名次 AS INTEGER) o,a.馬名 h,a.騎師 r,a.練馬師 t,aa.o ho,aa.c hc,bb.o ro,bb.c rc,cc.o tro,cc.c trc
from 
	RandLast1000Com a,
	OrderHorNam aa,OrderRadNam bb,OrderTraNam cc
where a.馬名=aa.n and a.騎師=bb.n and a.練馬師=cc.n
order by CAST(a.名次 AS INTEGER) asc;



select * from RandPredictHistory;
