-- 0.456380222734612	0.102061289749428	0.0406709945269131

select (
		--  speed dif of - a horse in dif length of race
		with 
		ana as ( select h ke1, meters ke2,(max(mark)-min(mark)) dif, count(*) c from NorRaw group by ke1,ke2 ) 
		select 1-((min(dif)+avg(dif)+max(dif))/3) ef from ana where c>1
	) hef, (
		--  speed dif of - a horse in dif length of race
		with 
		ana as ( select r ke1, meters ke2,(max(mark)-min(mark)) dif, count(*) c from NorRaw group by ke1,ke2 ) 
		select 1-((min(dif)+avg(dif)+max(dif))/3) ef from ana where c>1
	) ref, (
		--  speed dif of - a horse in dif length of race
		with 
		ana as ( select t ke1, meters ke2,(max(mark)-min(mark)) dif, count(*) c from NorRaw group by ke1,ke2 ) 
		select 1-((min(dif)+avg(dif)+max(dif))/3) ef from ana where c>1
	) tef;

	
-- dif speed of - dif meters, horse in all situation
with ana as ( select h ke1,meters ke2,(max(mark)-min(mark)) dif, count(*) c from NorRaw group by ke1,ke2 ) select ((min(dif)+avg(dif)+max(dif))/3) ef from ana where c>1;

-- speed dif of - in a race
with ana as ( select dt ke,(max(mark)-min(mark)) dif, count(*) c from NorRaw group by ke ) select ((min(dif)+avg(dif)+max(dif))/3) dif from ana where c>1;
