#!/usr/bin/python

import sqlite3

# print("Opened database successfully")
def exec(db,sql):
    conn = sqlite3.connect(db)
    c = conn.cursor()
    c.execute(sql)
    print()
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