
DROP TABLE IF EXISTS h;
CREATE TABLE h as select h,avg(mark) avo,count(*) c from NorRaw group by h;

DROP TABLE IF EXISTS r;
CREATE TABLE r as select r,avg(mark) avo,count(*) c from NorRaw group by r;

DROP TABLE IF EXISTS t;
CREATE TABLE t as select t,avg(mark),3 avo,count(*) c from NorRaw group by t;

commit;