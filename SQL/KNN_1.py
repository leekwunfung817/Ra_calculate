from KNN_1_data import result,data,predict
# https://docs.microsoft.com/en-us/windows/win32/fileio/maximum-file-path-limitation?tabs=cmd
command = '''

pip3 install sklearn==0.0
cd "C:/Users/ivan.lee.PRIMECREATION/Documents/ivan/Projects source/Others/h/Ra_calculate"
python3 KNN_1.py


'''

# X = [[0], [1], [2], [3]]
# y = [0, 0, 1, 1]

from sklearn.neighbors import KNeighborsRegressor

neigh = KNeighborsRegressor(n_neighbors=2)
print(len(data),len(result))
neigh.fit(data, result)
# KNeighborsRegressor(...)
# r1 = neigh.predict(data)
r1 = neigh.predict(predict)
for x in r1:
	print(x)
# [0.5]