import os
import numpy as np
import pandas as pd
from sklearn.neighbors import KNeighborsClassifier
from sklearn.metrics import mean_squared_error

TRAIN_DATA = os.path.normpath("C:/Users/amirr/OneDrive/Desktop/Amirreza/Uni/CISC 351/team project/CISC351_Project/data/basketball_train.csv")
VAL_DATA = os.path.normpath("C:/Users/amirr/OneDrive/Desktop/Amirreza/Uni/CISC 351/team project/CISC351_Project/data/basketball_val.csv")

Train_Data = pd.read_csv(TRAIN_DATA)
Val_Data = pd.read_csv(VAL_DATA)

Train_Data = Train_Data.drop(['Unnamed: 0', 'Player', 'Year'], axis=1)
Val_Data = Val_Data.drop(['Unnamed: 0', 'Player', 'Year'], axis=1)

X_train = Train_Data.replace(to_replace=['PG', 'PG-SG', 'PG-SF',
                                         'SG', 'SG-SF', 'SG-PF', 'SG-PG',
                                         'SF', 'SF-PF', 'SF-SG',
                                         'PF', 'PF-C', 'PF-SF',
                                          'C', 'C-PF'], value=[1, 1, 1,
                                                               2, 2, 2, 2,
                                                               3, 3, 3,
                                                               4, 4, 4,
                                                               5, 5])
y_train = 100 * X_train.pop('Salary')
y_train = y_train.astype(int)
Columns = list(X_train.columns)

X_val = Val_Data.replace(to_replace=['PG', 'PG-SG', 'PG-SF',
                                     'SG', 'SG-SF', 'SG-PF', 'SG-PG',
                                     'SF', 'SF-PF', 'SF-SG',
                                     'PF', 'PF-C', 'PF-SF',
                                      'C', 'C-PF'], value=[1, 1, 1,
                                                           2, 2, 2, 2,
                                                           3, 3, 3,
                                                           4, 4, 4,
                                                           5, 5])
y_val = 100 * X_val.pop('Salary')
y_val = y_val.astype(int)

Model = KNeighborsClassifier(n_neighbors=7)
Model = Model.fit(X_train, y_train)
score = Model.score(X_val, y_val)
y_perd = Model.predict(X_val)
mse =mean_squared_error(y_val, y_perd)

feat_imp_data = pd.DataFrame(columns=Columns)
print(feat_imp_data)
result = dict.fromkeys(Columns, )

c = range(5)
for count in c:

    for column in feat_imp_data:
        val_SL = X_val.copy()
        val_SL[column] = np.random.permutation(val_SL[column])
        data = {column : [(abs(score - Model.score(val_SL, y_val))/score)*100]}
        result[column] = result.get(column) + ((abs(score - Model.score(val_SL, y_val))/score)*100)
        if count == 4:
            result[column] /= 5

print(result)
