
delete from Cache where `key`='havm';
insert into Cache
select 
	'havm' ke,
	avg(case when m<0 then m*-1 else m end) val
from (
	select 
		(h.avo-NorRaw.mark) m
	from h,NorRaw
	where h.h=NorRaw.h
	group by h.h
);

delete from Cache where `key`='ravm';
insert into Cache
select 
	'ravm' ke,
	avg(case when m<0 then m*-1 else m end) val
from (
	select 
		(r.avo-NorRaw.mark) m 
	from r,NorRaw
	where r.r=NorRaw.r
	group by r.r
);

delete from Cache where `key`='tavm';
insert into Cache
select 
	'tavm' ke,
	avg(case when m<0 then m*-1 else m end) val
from (
	select 
		(t.avo-NorRaw.mark) m 
	from t,NorRaw
	where t.t=NorRaw.t
	group by t.t
);

commit;
