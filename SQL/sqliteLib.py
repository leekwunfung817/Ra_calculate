#!/usr/bin/python

import sqlite3
# ATTACH DATABASE 'SomeTableFile.db' AS stf;
# print("Opened database successfully")

def exec(db,sql):
    conn = None
    if type(db) is list:
        conn = sqlite3.connect(db[0])
        for dbn in db:
            c = conn.cursor()
            lsql = "ATTACH DATABASE '"+dbn+".db' AS "+dbn.replace('/','').replace('.','')
            # print(lsql)
            c.execute(lsql)
    else:
        conn = sqlite3.connect(db)
    c = conn.cursor()
    c.execute(sql)
    # print()
    rowCount = 0
    for row in c:
        print('Row:',rowCount+1)
        colCount = 0
        for ele in row:
            print(c.description[0][colCount], ':' ,ele)
            colCount += 1
        rowCount += 1

    # print("Table created successfully")
    conn.commit()
    conn.close()