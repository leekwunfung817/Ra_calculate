

DROP TABLE IF EXISTS h;
CREATE TABLE h as
select h,round(avg(mark),3) avo,count(*) c from NorRaw
group by h
;

DROP TABLE IF EXISTS r;
CREATE TABLE r as
select r,round(avg(mark),3) avo,count(*) c from NorRaw
group by r
;

DROP TABLE IF EXISTS t;
CREATE TABLE t as
select t,round(avg(mark),3) avo,count(*) c from NorRaw
group by t
;


