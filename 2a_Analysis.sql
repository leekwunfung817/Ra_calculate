--
with L as (select dt,h,r,t,mark,wb ana_val  FROM NorRaw),L1 as (SELECT dt,h,r,t,mark,round(ana_val,1) ana_val FROM L where ana_val is not null)
select ana_val `比例賠率`,avg(mark) 平均勝率,'越低賠率0.0，越高勝率(影響較高)' result from L1 group by ana_val order by 平均勝率 asc;
--
with L as (select dt,h,r,t,mark,rw ana_val  FROM NorRaw),L1 as (SELECT dt,h,r,t,mark,round(ana_val,1) ana_val FROM L where ana_val is not null)
select ana_val `比例實際負磅(馬)`,avg(mark) 平均勝率,'實際負磅(影響較低)' result from L1 group by ana_val order by ana_val asc;
--
with L as (select dt,h,r,t,mark,cw ana_val  FROM NorRaw),L1 as (SELECT dt,h,r,t,mark,round(ana_val,1) ana_val FROM L where ana_val is not null)
select ana_val `比例排位體重(裝備，馬和人)`,avg(mark) 平均勝率,'排位體重 越高，越高勝率(影響較高)' result from L1 group by ana_val order by ana_val asc;
--
with L as (select dt,h,r,t,mark,rww ana_val  FROM NorRaw),L1 as (SELECT dt,h,r,t,mark,round(ana_val,1) ana_val FROM L where ana_val is not null)
select ana_val `比例體重(裝備和人)`,avg(mark) 平均勝率,'裝備和人 體重 越中等，越高勝率(影響較高)' result from L1 group by ana_val order by ana_val asc;

with L as (select dt,h,r,t,mark,p ana_val  FROM NorRaw),L1 as (SELECT dt,h,r,t,mark,round(ana_val,1) ana_val FROM L where ana_val is not null)
select ana_val `p`,avg(mark) 平均勝率,'排位越低，勝率越高(影響較高)' result from L1 group by ana_val order by ana_val asc;
