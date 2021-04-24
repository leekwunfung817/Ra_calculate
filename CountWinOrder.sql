What is 名次=WV?

DROP VIEW OrderHorNam;
CREATE VIEW OrderHorNam AS
SELECT avg(o) o,n,count(*) c from 
(
	SELECT 
		CAST(名次 AS INTEGER) o,
		馬名 n
	FROM LocalResults 
)
where o>0
group by n
order by o asc;

DROP VIEW OrderRadNam;
CREATE VIEW OrderRadNam AS
SELECT avg(o) o,n,count(*) c from 
(
	SELECT 
		CAST(名次 AS INTEGER) o,
		騎師 n
	FROM LocalResults 
)
where o>0
group by n
order by o asc;

DROP VIEW OrderTraNam;
CREATE VIEW OrderTraNam AS
SELECT avg(o) o,n,count(*) c from 
(
	SELECT 
		CAST(名次 AS INTEGER) o,
		練馬師 n
	FROM LocalResults 
)
where o>0
group by n
order by o asc;


select o from OrderHorNam;
