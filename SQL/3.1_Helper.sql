
with 
avg as (select p ke,avg(mark) mark from NorRaw group by ke) 
select ke,mark from avg order by ke asc; -- average position speed
with avg as (select rw ke,avg(mark) mark from NorRaw group by ke) select ke,mark from avg order by mark asc; -- average real weight
with avg as (select cw ke,avg(mark) mark from NorRaw group by ke) select ke,mark from avg order by mark asc; -- average comparitive weight
with avg as (select rww ke,avg(mark) mark from NorRaw group by ke) select ke,mark from avg order by mark asc; -- average rider with weight
with avg as (select wb ke,avg(mark) mark from NorRaw group by ke) select ke,mark from avg order by mark asc; -- average win bouns
