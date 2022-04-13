import pandas as pd
import time,datetime
import calendar
import numpy as np

orgfile='../../input/inp.csv'
jxfile='../../input/jixing.csv'
pdfile='../../input/pd.csv.bak'
enginefile='../../input/engine.csv'

orgdata=pd.read_csv(orgfile,encoding='gbk')
jxdata=pd.read_csv(jxfile,encoding='gbk')
pddata=pd.read_csv(pdfile,encoding='gbk')
enginedata=pd.read_csv(enginefile,encoding='gbk')

data1 = {}
data2 = {}
data3 = {}
data4 = {}
#depart-----------------------------------------------
data1=pd.DataFrame({'airtype':orgdata['机型'],'airportcode':orgdata['出发机场码'],'time':orgdata['出发时间']})
#处理缺失
data1['airtype']=data1['airtype'].fillna('738')
#print(data1.isnull().sum())
#匹配机型
tmp=pd.merge(data1,jxdata,on=['airtype'],how='left')
data1['airtype']=tmp['air']
#匹配跑道
tmp=pd.merge(data1,pddata,on=['airportcode'],how='left')
data1=tmp
data1.reset_index(drop=True,inplace=True)

#arrive------------------------------------------------
data2=pd.DataFrame({'airtype':orgdata['机型'],'airportcode':orgdata['到达机场码'],'time':orgdata['到达时间']})
data2['airtype']=data2['airtype'].fillna('738')
#匹配机型
tmp=pd.merge(data2,jxdata,on=['airtype'],how='left')
data2['airtype']=tmp['air']
#匹配跑道
tmp=pd.merge(data2,pddata,on=['airportcode'],how='left')
data2=tmp

#transfer-----------------------------------------------
data3=pd.DataFrame({'airtype':orgdata['机型'],'airportcode':orgdata['经停机场'],'time':orgdata['经停出发']})   #经停出发
data4=pd.DataFrame({'airtype':orgdata['机型'],'airportcode':orgdata['经停机场'],'time':orgdata['经停到达']})   #经停到达
data3['airtype']=data3['airtype'].fillna('738')
data4['airtype']=data4['airtype'].fillna('738')
#匹配机型
tmp=pd.merge(data3,jxdata,on=['airtype'],how='left')
data3['airtype']=tmp['air']
#去除缺失值
data3 = data3.dropna()
data3.reset_index(drop=True,inplace=True)
tmp=pd.merge(data4,jxdata,on=['airtype'],how='left')
data4['airtype']=tmp['air']
data4 = data4.dropna()
data4.reset_index(drop=True,inplace=True)

#匹配跑道
tmp=pd.merge(data3,pddata,on=['airportcode'],how='left')
data3=tmp
tmp=pd.merge(data4,pddata,on=['airportcode'],how='left')
data4=tmp

#transfer distribution--------------------------------- 
df1=pd.concat([data1,data3])
df1.reset_index(drop=True,inplace=True)
df2=pd.concat([data2,data4])
df2.reset_index(drop=True,inplace=True)

#匹配排放量
tmp=pd.merge(df1,enginedata,on=['airtype'],how='left')
departdata=tmp
tmp1=pd.merge(df1,enginedata,on=['airtype'],how='left')
departdata1=tmp1

tmp=pd.merge(df2,enginedata,on=['airtype'],how='left')
arrivedata=tmp
tmp1=pd.merge(df2,enginedata,on=['airtype'],how='left')
arrivedata1=tmp1

del departdata1['time']
del arrivedata1['time']
departdata1.to_csv('../../output/tmp/out_departdata.csv',mode='w',encoding='utf-8-sig' ,sep=',',index=False,header=False)
arrivedata1.to_csv('../../output/tmp/out_arrivedata.csv',mode='w',encoding='utf-8-sig' ,sep=',',index=False,header=False)

#print(departdata.isnull().sum())
#print(arrivedata.isnull().sum())

departdata['time'] = pd.to_datetime(departdata['time'])
arrivedata['time'] = pd.to_datetime(arrivedata['time'])

timeArray = time.strptime(str(departdata['time'][0]), "%Y-%m-%d %H:%M:%S")
YYYYMMDD = time.strftime("%Y-%m-%d", timeArray) 
YYYY = time.strftime("%Y", timeArray)
MM = time.strftime("%m", timeArray)
DD = time.strftime("%d", timeArray)
monthRange = calendar.monthrange(int(YYYY),int(MM))
totalday=monthRange[1]
sdate=str((YYYY)+'-'+str(MM)+'-'+ str(DD) + ' 00')
edate=str((YYYY)+'-'+str(MM)+'-'+ str(DD) + ' 23')
tmpdate=datetime.datetime.strptime(edate,'%Y-%m-%d %H')
outdate=(tmpdate + datetime.timedelta(hours=1)).strftime('%Y-%m-%d %H')

#daily=pd.date_range(sdate,outdate,freq='D')
hourly=pd.date_range(sdate,outdate,freq='H')
#print(hourly)
code=['AAT','ACX','AEB','AHJ','AKU','AQG','AVA','AXF','BAR','BAV','BFJ','BHY','BPE','BPL','BPX','BSD','BZX','CAN','CDE','CGD','CGO','CGQ','CHG','CIF','CIH','CKG','CSX','CTU','CWJ','CZX','DAT','DAX','DBC','DCY','DDG','DIG','DLC','DLU','DNH','DOY','DQA','DSN','DTU','DYG','EJN','ENH','ENY','ERL','FOC','FUG','FUO','FYJ','FYN','GMQ','GOQ','GXH','GYS','GYU','HAK','HBQ','HCJ','HDG','HEK','HET','HFE','HGH','HIA','HJJ','HLD','HLH','HMI','HNY','HPG','HRB','HSN','HTN','HTT','HUO','HUZ','HXD','HYN','HZG','HZH','INC','IQM','IQN','JDZ','JGD','JGN','JGS','JHG','JIC','JIQ','JJN','JMJ','JMU','JNG','JNZ','JSJ','JUH','JUZ','JXA','JZH','KCA','KGT','KHG','KHN','KJH','KJI','KMG','KOW','KRL','KRY','KWE','KWL','LCX','LDS','LFQ','LHW','LJG','LLB','LLV','LNJ','LNL','LPF','LUM','LXA','LYA','LYG','LYI','LZH','LZO','LZY','MDG','MIG','MXZ','NAO','NAY','NBS','NDG','NGB','NGQ','NKG','NLH','NLT','NNG','NNY','NTG','NZH','NZL','OHE','PEK','PKX','PVG','PZI','QSZ','RHT','RIZ','RKZ','RLK','RQA','SHA','SHE','SJW','SQD','SQJ','SWA','SYM','SYX','SZX','TAO','TCG','TCZ','TEN','TGO','THQ','TLQ','TNA','TNH','TSN','TVS','TWC','TXN','TYC','TYN','UCB','URC','UYN','WDS','WEF','WEH','WGN','WMT','WNH','WNZ','WUA','WUH','WUS','WUT','WUX','WUZ','WXN','XAI','XFN','XIC','XIL','XIY','XMN','XNN','XUZ','YBP','YCU','YIC','YIE','YIH','YIN','YIW','YKH','YNJ','YNT','YNZ','YSQ','YTY','YUN','YUS','YYA','YZY','ZAT','ZHA','ZHY','ZQZ','ZUH','ZYI']
list=[]
for n in code:
	'''
	dlist=[]
	alist=[]
	for i in range(totalday):
		sday=daily[0+i]
		eday=daily[1+i]
		con1=departdata['time']>=sday
		con2=departdata['time']< eday
		con3=arrivedata['time']>=sday
		con4=arrivedata['time']< eday
		dlist.append(n)
		alist.append(n)
		dlist.append(departdata[con1&con2].airportcode.tolist().count(n))
		alist.append(arrivedata[con3&con4].airportcode.tolist().count(n))
		dd=np.array(dlist)
		aa=np.array(alist)
		print(dd)
		print(aa)
	'''
	dlist=[]
	alist=[]
	for j in range(0,24):
		shour=hourly[0+j]
		ehour=hourly[1+j]
		con1=departdata['time']>=shour
		con2=departdata['time']< ehour
		con3=arrivedata['time']>=shour
		con4=arrivedata['time']< ehour
		dlist.append(departdata[con1&con2].airportcode.tolist().count(n))
		alist.append(arrivedata[con3&con4].airportcode.tolist().count(n))

	newlist = [x + y for x, y in zip(dlist, alist)]
	numtol = sum(newlist)
	if numtol == 0:
		li = [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	else:
		li = [x/numtol for x in newlist]
	#time zone shift
	li=np.roll(li, -8).tolist()
	li.append(n)
	li=np.array(li)
	list.append(li)
#print(list)
col=['0','1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','IATA']
#df =pd.DataFrame(columns=col,data=li)
df =pd.DataFrame(data=list)
df.columns = col
df.to_csv('../../input/timeprofile.csv',mode='w',encoding='utf-8-sig' ,sep=',',index=False) 
print('Successful.')
