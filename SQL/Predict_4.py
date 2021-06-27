import sqliteLib

dbList = [
    '../A_Ra',
    '../B_PreProcess'
]
sqliteLib.exec(dbList,'''
DROP TABLE IF EXISTS B_PreProcess.Rand;
''')
sqliteLib.exec(dbList,'''
CREATE TABLE B_PreProcess.Rand as 
	select --潘明輝(-2)
		meter*1.0 meter,
		case when instr(馬名, '(')>=1 then (substr(馬名, 0, instr(馬名, '('))) else 馬名 end h,
		case when instr(騎師, '(')>=1 then (substr(騎師, 0, instr(騎師, '('))) else 騎師 end r,
		case when instr(練馬師, '(')>=1 then (substr(練馬師, 0, instr(練馬師, '('))) else 練馬師 end t,
		馬名 h,
		騎師 r,
		練馬師 t,
		b.*,
		今季獎金*1.0 wb,
		負磅*1.0 rw,
		檔位*1.0 p
	from A_Ra.RaceCard b
	where dt=(select dt from RaceCard order by dt desc limit 1)
;
''')