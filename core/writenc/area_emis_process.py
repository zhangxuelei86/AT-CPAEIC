#!/usr/bin/env python
#coding=utf-8
import os,sys,csv
import numpy as np
import pandas as pd
import time,datetime,calendar
from datetime import datetime as dt
from netCDF4 import Dataset
import warnings
warnings.filterwarnings('ignore')

start = time.time()
modeltype='CMAQ'
tempdate=os.getenv('tempdate')
file_desc = "Gridded emissions, created by the REPT v0.1" + \
            " on " + dt.strftime(dt.now(), '%Y-%m-%d %H:%M:%S')

if modeltype=='CMAQ':
	stime='2021124000000'   #+8
	gridcro2d='../../input/GRIDCRO2D_d01'
	boundary = Dataset(gridcro2d, 'r')
	lon = boundary.variables['LON'][0, 0, :, :]
	lat = boundary.variables['LAT'][0, 0, :, :]
	hour_factor_id=pd.read_csv('../../input/timeprofile.csv')
	speciate = pd.read_csv('../../input/speciate_cb06_ae6.csv')
	emis=pd.read_csv('../../core/intersect/d01/emis.csv')
	tmp=pd.merge(emis,hour_factor_id,on=['IATA'],how='left')
	tmp=tmp.fillna('0')
	so2=tmp['so2'].values.reshape(np.shape(lon))
	nox=tmp['nox'].values.reshape(np.shape(lon))
	hc =tmp['hc'].values.reshape(np.shape(lon))
	co =tmp['co'].values.reshape(np.shape(lon))
	pm25=tmp['pm25'].values.reshape(np.shape(lon))
	nt=[]
	for t in range(0,24):
		timf=tmp[str(t)].values.reshape(np.shape(lon))
		nt.append(timf)
	# 
	speciaten_list = []
	for i in range(len(speciate)):
		  speciaten_list.append({
			  'species': speciate['species'][i],
			  'mw': speciate['molecular_weights'][i],
			  'formula': speciate['formula'][i],
			  'units': speciate['units'][i],
		  })

	speciatenum=len(speciaten_list)
	# define outfile name
	outfile = '../../output/ARarea.nc'
	metnc = Dataset(gridcro2d)

	# create and outline NetCDF file
	rootgrp = Dataset(outfile, 'w', format='NETCDF3_CLASSIC')
	_ = rootgrp.createDimension('TSTEP', None)
	_ = rootgrp.createDimension('DATE-TIME', 2)
	_ = rootgrp.createDimension('LAY', 1)
	_ = rootgrp.createDimension('VAR', speciatenum)  # number of variables/species
	_ = rootgrp.createDimension('ROW', len(lon[:, 0]))  # Domain: number of rows
	_ = rootgrp.createDimension('COL', len(lon[0, :]))  # Domain: number of columns
	# define TFLAG Variable
	TFLAG = rootgrp.createVariable('TFLAG', 'i4', ('TSTEP', 'VAR', 'DATE-TIME',), zlib=False)
	TFLAG.units = '<YYYYDDD,HHMMSS>'
	TFLAG.long_name = 'TFLAG           '
	TFLAG.var_desc = 'Timestep-valid flags:  (1) YYYYDDD or (2) HHMMSS                                '
	# define variables and attribute definitions
	varl = ''
	for nspc in range(speciatenum):
		rootgrp.createVariable(speciaten_list[nspc]['species'], 'f4', ('TSTEP', 'LAY', 'ROW', 'COL'))
		rootgrp.variables[speciaten_list[nspc]['species']].long_name = '%-16s' % speciaten_list[nspc]['species']
		rootgrp.variables[speciaten_list[nspc]['species']].units = '%-16s' % speciaten_list[nspc]['units']
		rootgrp.variables[speciaten_list[nspc]['species']].var_desc = '%-14s' % 'Model species ' + '%-66s' % speciaten_list[nspc]['species']
		varl += speciaten_list[nspc]['species'].ljust(16)
	# global attributes
	rootgrp.setncatts(metnc.__dict__)     # copy original file attributes
	rootgrp.TSTEP = int(10000)            # time step     e.g. 10000 (1 hour)
	rootgrp.NLAYS = 1                     # number of vertical layers
	rootgrp.NVARS = speciatenum           # number of variables/species
	#rootgrp.VGLVLS = np.float32(eta)      # vertical layer locations
	rootgrp.GDNAM = 'CMAQ Emissions  '    # none
	rootgrp.UPNAM = 'REPT by Geek    '    # none
	rootgrp.setncattr('VAR-LIST', varl)   # use this b/c the library does not like hyphens
	rootgrp.FILEDESC = file_desc

	secs = time.mktime(time.strptime("%s" % stime, "%Y%j%H%M%S"))
	gmt_shift = time.strftime("%H", time.localtime(secs))
	tflag = np.ones((len(nt), speciatenum, 2), dtype=np.int32)

	for hr in range(len(nt)):
		gdh = time.strftime("%Y%j %H0000", time.localtime(secs + hr * 3600))
		a_date, ghr = map(int, gdh.split())
		tflag[hr, :, 0] = tflag[hr, :, 0] * a_date
		tflag[hr, :, 1] = tflag[hr, :, 1] * ghr

	rootgrp.variables['TFLAG'][:] = tflag

	# utc
	for hour in range(len(nt)):
		# emission allocate 
		for rowline in range(speciatenum):
			if speciaten_list[rowline]['units'] == 'g/s':   
			   rootgrp.variables[speciaten_list[rowline]['species']][hour, 0, :, :] = eval(str(speciaten_list[rowline]['formula'])) * nt[hour].astype(np.float) / 3600 
			else:     # moles/s
			   rootgrp.variables[speciaten_list[rowline]['species']][hour, 0, :, :] = eval(str(speciaten_list[rowline]['formula'])) * nt[hour].astype(np.float) / float(speciaten_list[rowline]['mw']) / 3600 

	rootgrp.close()

else:
     print('Input Model Type Error !')

end=time.time()
print(f'Generating emission file time: %.2f Seconds'%(end-start))
