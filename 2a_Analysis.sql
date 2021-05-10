------------------------------------------------------------------------------------------------------------------------------------------------------
with 
L as (select dt,h,r,t,mark,wb ana_val  FROM NorRaw),L1 as (SELECT dt,h,r,t,mark,ana_val ana_val FROM L where ana_val is not null)
select ana_val `比例賠率`,avg(mark) 平均勝率,'越低賠率，越高勝率(影響較高)' result from L1 group by ana_val order by ana_val asc
------------------------------------------------------------------------------------------------------------------------------------------------------
with L as (select dt,h,r,t,mark,rw ana_val  FROM NorRaw),L1 as (SELECT dt,h,r,t,mark,round(ana_val,1) ana_val FROM L where ana_val is not null)
select ana_val `比例實際負磅(馬)`,avg(mark) 平均勝率,'實際負磅(影響較低)' result from L1 group by ana_val order by ana_val asc;
------------------------------------------------------------------------------------------------------------------------------------------------------
with L as (select dt,h,r,t,mark,cw ana_val  FROM NorRaw),L1 as (SELECT dt,h,r,t,mark,round(ana_val,1) ana_val FROM L where ana_val is not null)
select ana_val `比例排位體重(裝備，馬和人)`,avg(mark) 平均勝率,'排位體重 越高，越高勝率(影響較高)' result from L1 group by ana_val order by ana_val asc;
------------------------------------------------------------------------------------------------------------------------------------------------------
with L as (select dt,h,r,t,mark,rww ana_val  FROM NorRaw),L1 as (SELECT dt,h,r,t,mark,round(ana_val,1) ana_val FROM L where ana_val is not null)
select ana_val `比例體重(裝備和人)`,avg(mark) 平均勝率,'裝備和人 體重 越中等，越高勝率(影響較高)' result from L1 group by ana_val order by ana_val asc;
------------------------------------------------------------------------------------------------------------------------------------------------------
with L as (select dt,h,r,t,mark,p ana_val  FROM NorRaw),L1 as (SELECT dt,h,r,t,mark,round(ana_val,1) ana_val FROM L where ana_val is not null)
select ana_val `p`,avg(mark) 平均勝率,'排位越低，勝率越高(影響較高)' result from L1 group by ana_val order by ana_val asc;
------------------------------------------------------------------------------------------------------------------------------------------------------

delete from Cache where `key`='wb';
insert into Cache select 'wb' ke,(with  L as (select dt,h,r,t,mark,wb ana_val  FROM NorRaw),L1 as (SELECT dt,h,r,t,mark,round(ana_val,4) ana_val FROM L where ana_val is not null),L2 as (select avg(mark) avgmark from L1 group by ana_val order by avgmark asc) select (max(avgmark)-min(avgmark)) 影響率 from L2) val;
delete from Cache where `key`='rw';
insert into Cache select 'rw' ke,(with  L as (select dt,h,r,t,mark,rw ana_val  FROM NorRaw),L1 as (SELECT dt,h,r,t,mark,round(ana_val,4) ana_val FROM L where ana_val is not null),L2 as (select avg(mark) avgmark from L1 group by ana_val order by avgmark asc) select (max(avgmark)-min(avgmark)) 影響率 from L2) val;
delete from Cache where `key`='cw';
insert into Cache select 'cw' ke,(with  L as (select dt,h,r,t,mark,cw ana_val  FROM NorRaw),L1 as (SELECT dt,h,r,t,mark,round(ana_val,4) ana_val FROM L where ana_val is not null),L2 as (select avg(mark) avgmark from L1 group by ana_val order by avgmark asc) select (max(avgmark)-min(avgmark)) 影響率 from L2) val;
delete from Cache where `key`='rww';
insert into Cache select 'rww' ke,(with  L as (select dt,h,r,t,mark,rww ana_val  FROM NorRaw),L1 as (SELECT dt,h,r,t,mark,round(ana_val,4) ana_val FROM L where ana_val is not null),L2 as (select avg(mark) avgmark from L1 group by ana_val order by avgmark asc) select (max(avgmark)-min(avgmark)) 影響率 from L2) val;
delete from Cache where `key`='p';
insert into Cache select 'p' ke,(with  L as (select dt,h,r,t,mark,p ana_val  FROM NorRaw),L1 as (SELECT dt,h,r,t,mark,round(ana_val,4) ana_val FROM L where ana_val is not null),L2 as (select avg(mark) avgmark from L1 group by ana_val order by avgmark asc) select (max(avgmark)-min(avgmark)) 影響率 from L2) val;
