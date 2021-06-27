
DROP TABLE IF EXISTS B_PreProcess.Rand;
CREATE TABLE B_PreProcess.Rand as 
	select --潘明輝(-2)
		case when instr(馬名, '(')>=1 then (substr(馬名, 0, instr(馬名, '('))) else 馬名 end h,
		case when instr(騎師, '(')>=1 then (substr(騎師, 0, instr(騎師, '('))) else 騎師 end r,
		case when instr(練馬師, '(')>=1 then (substr(練馬師, 0, instr(練馬師, '('))) else 練馬師 end t,
		馬名 h,
		騎師 r,
		練馬師 t,
		b.*,
		今季獎金 wb,
		負磅 rw,
		檔位 p
	from RaceCard b
	where dt=(select dt from RaceCard order by dt desc limit 1)
;
