#coding:utf-8
import requests
from lxml import etree
import re
import time,datetime
from html.parser import HTMLParser
from lxml import html
import json
import pandas as pd
import concurrent.futures

def chaxun(start,end,date):
    cookies = {
        'arrCityPy': start,
        'depCityPy': end,
    }

    headers = {
        'Connection': 'keep-alive',
        'Pragma': 'no-cache',
        'Cache-Control': 'no-cache',
        'sec-ch-ua': '^\\^',
        'sec-ch-ua-mobile': '?0',
        'Upgrade-Insecure-Requests': '1',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
        'Sec-Fetch-Site': 'none',
        'Sec-Fetch-Mode': 'navigate',
        'Sec-Fetch-User': '?1',
        'Sec-Fetch-Dest': 'document',
        'Accept-Language': 'zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7',
    }

    params = (
        ('unionId', '427'),
        ('godate', date),
        ('searchType', '0'),
    )

    #response = requests.get(f'https://jipiao.114piaowu.com/{start}-{end}.html', headers=xundaili.headers, proxies=xundaili.proxy, params=params, cookies=cookies, verify=False,allow_redirects=False, timeout = 5)
    response = requests.get(f'https://jipiao.114piaowu.com/{start}-{end}.html', headers=headers,params=params, cookies=cookies)
    return response.content.decode('utf-8')

def jianxi(html1):
    xp = etree.HTML(html1)
    hangban_data = []
    #hangban_list = xp.xpath('//*[@class="jp_list"]//*[@class="mainDiv66"]')
    hangban_list = xp.xpath('//*[@class="jp_list"]//*[@class="mainDiv66"]')
    test=xp.xpath('//*[@class="yd_list"]//input[@type="hidden"]/@value')

    for i in range(0,len(test)):
        #print(test[i].find('fla'))
        if 'planeType' in test[i]:
            data=json.loads(test[i])
            start_date=data['depDate']
            start_time=data['depTime']
            st=re.sub("\D", "", start_date)+start_time
            timeArray1 = time.strptime(str(st), "%Y%m%d%H%M")
            sd = time.strftime("%Y-%m-%d %H:%M:%S", timeArray1)
            start_address=data['orgCityName']
            start_code=data['orgCity']
            end_date=data['arrDate']
            end_time=data['arriTime']
            et=re.sub("\D", "", end_date)+end_time
            timeArray2 = time.strptime(str(et), "%Y%m%d%H%M")
            ed = time.strftime("%Y-%m-%d %H:%M:%S", timeArray2)
            end_address=data['dstCityName']
            end_code=data['dstCity']
            flight_number=data['flightNo']
            airways_cn=data['airwaysCn']
            plane_type=data['planeType']
            work_time=data['workTime']
            air_code=re.sub("\D", "", plane_type)
            hangban_data.append({'sdate': sd,'scity': start_address , 'scitycode': start_code, 'edate': ed, 'ecity': end_address , 'ecitycode': end_code, 'flightnu': flight_number, 'airways': airways_cn, 'planetype': plane_type, 'aircode': air_code , 'worktime': work_time })
    return hangban_data

if __name__ == '__main__':
    allcities=['beijing','changchun','changsha','chengdu','dalian','foshan','fuzhou','guangzhou','guilin','haerbin','haikou','hangzhou','hefei','huhehaote','jinan','jingdezhen','jiuzhaigou','jiuquan','kashi','kuerle','kunming','lasa','lanzhou','manzhouli','mohe','mudanjiang','nanchang','nanjing','ningbo','penglai','qingdao','sanya','shanghai','shenzhen','shennongjia','shenyang','shijiazhuang','suzhou','taiyuan','tianjin','wenzhou','wulanhaote','wulumuqi','wuxi','wuhan','xian','xining','xishuangbanna','xiamen','xuzhou','yantai','yichang','yinchuan','zhangjiajie','zhangjiakou','zhengzhou','chongqing','zhoushan','zhuhai']
    print(len(allcities))
    date = '2022-04-12'
    start_time = time.time()
    li=[]
    for startcity in allcities:
        for endcity in allcities:
            if startcity != endcity:
                start1 = startcity
                end1 = endcity
                print(date+' : '+startcity+' to '+endcity)
                html1 = chaxun(start1,end1,date)
                datas = jianxi(html1)
                #print(datas)
                if len(datas) != 0:
                    print(len(datas))
                    for data in datas:
                        li.append(data)
                else:
                    print('未查询到相关数据')
    df =pd.DataFrame(li)
    df_copy=df.drop_duplicates()
    df_copy.to_csv('../../input/inp.csv',mode='w',encoding='utf-8-sig' ,sep=',',index=False)
    end_time = time.time()
    print(f'运行了{end_time - start_time}秒')

