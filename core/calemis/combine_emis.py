import pandas as pd

infile1='../../output/tmp/demis.csv'
infile2='../../output/tmp/aemis.csv'

data1=pd.read_csv(infile1,encoding='gbk')
data2=pd.read_csv(infile2,encoding='gbk')
data3=data1+data2
#print(data1)
data3['IATA']=data1['IATA']
#print(data3)
data3.to_csv('../../output/allemis.csv',mode='w',encoding='utf-8-sig' ,sep=',',index=False)

#print(data3['airportcode'])
