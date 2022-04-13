from mpl_toolkits.basemap import Basemap
import os
import numpy as np
import geopandas as gpd
import pandas as pd
from osgeo import ogr
from shapely.ops import transform
from shapely.geometry import Point, Polygon
from netCDF4 import Dataset
import re
from shapely.ops import cascaded_union
from rtree import index
from shapely.strtree import STRtree
import sys
import warnings
warnings.filterwarnings('ignore')

dom=sys.argv[1]
model='CMAQ'

if model == 'CMAQ':
    infile1 = 'GRIDCRO2D_'+dom
    infile2 = 'GRIDDOT2D_'+dom
    a=Dataset(infile1)
    b=Dataset(infile2)
    ds_lon=a.variables['LON'][0,0,:,:]
    ds_lat=a.variables['LAT'][0,0,:,:]
    c_lon=b.variables['LOND'][0,0,:,:]
    c_lat=b.variables['LATD'][0,0,:,:]
    ncols=a.NCOLS
    nrows=a.NROWS
    lat1=a.P_ALP
    lat2=a.P_BET
    lono=a.P_GAM
    lato=a.YCENT
    dxdy=a.XCELL
    domain=infile1.split('_')[1]

elif model == 'WRFCHEM':
    infile1 = 'geo_em.'+dom+'.nc'
    a=Dataset(infile1)
    ds_lon=a.variables['XLONG_M'][0, :, :]
    ds_lat=a.variables['XLAT_M'][0, :, :]
    c_lon=a.variables['XLONG_C'][0, :, :]
    c_lat=a.variables['XLAT_C'][0, :, :]
    ncols=a.dimensions['west_east']
    nrows=a.dimensions['south_north']
    lat1=a.TRUELAT1
    lat2=a.TRUELAT2
    lono=a.STAND_LON
    lato=a.MOAD_CEN_LAT
    dxdy=a.DX
    domain=infile1.split('.')[1]

else:
    print('Invalid inputs')

grd=str(int(dxdy/1000))

print('---------------------------------------------------------------------------------------')
print('----------------------------------')
print('REGRID EMISSION TO WRFCHEM/CMAQ/CAMx GRID for resolution ', grd, 'km')
print('----------------------------------')

# STEP 1 Process WRF grid parameters + extents
print('Step 1: Process WRF grid parameters + extents')

print('\tFile processed: ', infile1 )
print('\tTRUELAT1: ', lat1 )
print('\tTRUELAT2: ', lat2 )
print('\tLAT ORIGIN: ', lato )
print('\tLON ORIGIN: ', lono )
print('\tRESOLUTION(km): ',grd)

# Draw a basemap projection according to WRF grid parameters
# https://fabienmaussion.info/2018/01/06/wrf-projection/
if model == 'CMAQ':
    m = Basemap(width=dxdy*(ncols-1),height=dxdy*(nrows-1),
            rsphere=(6370000.00,6370000.00),\
            resolution='l',area_thresh=1000.,projection='lcc',\
            lat_1=lat1,lat_2=lat2,lat_0=lato,lon_0=lono)

elif model == 'WRFCHEM':
    m = Basemap(width=dxdy*(len(ncols)-1),height=dxdy*(len(nrows)-1),
            rsphere=(6370000.00,6370000.00),\
            resolution='l',area_thresh=1000.,projection='lcc',\
            lat_1=lat1,lat_2=lat2,lat_0=lato,lon_0=lono)

else:
    print('')

# Create in terms of meters from the edge of the basemap projection
x,y = c_lon, c_lat  # Multiplies the original lat and lon by the basemap projection

# STEP 2 Create a CAMQ polygons shapefile
# Export to shapefile
print('Step 2: Create a CMAQ polygons shapefile')
cmaqname = "CMAQ_"+grd+"KM"
geometry = []
geomcmaq = []
resol_new = float(grd)/2*1000 # create a variable that cuts half of one grid cell --> Converts cross centers to point edges

# Set index for cutting the border cells from WRF grid to fit the CAMx grid
ind_start = 0
ind_end   = 0
lon1d=[]
lat1d=[]
print('\tSN Grid: ', range(ind_start,np.shape(ds_lon)[0]-ind_end))
print('\tWE Grid: ', range(ind_start,np.shape(ds_lon)[1]-ind_end))
for i in range(ind_start,np.shape(ds_lon)[0]-ind_end):
    for j in range(ind_start,np.shape(ds_lon)[1]-ind_end):

        p1 = (x[i][j],y[i][j])
        p2 = (x[i][j+1],y[i][j+1])
        p3 = (x[i+1][j+1],y[i+1][j+1])
        p4 = (x[i+1][j],y[i+1][j])
     
        box = [p1,p2,p3,p4]
        geometry.append(Polygon(box))

        lon1d.append(ds_lon[i][j].astype(np.float64))
        lat1d.append(ds_lat[i][j].astype(np.float64))

driver = ogr.GetDriverByName('Esri Shapefile')
ds = driver.CreateDataSource(cmaqname+'.shp')
layer = ds.CreateLayer('', None, ogr.wkbPolygon)

# Add one attribute
layer.CreateField(ogr.FieldDefn('id', ogr.OFTInteger))
layer.CreateField(ogr.FieldDefn('XLONG', ogr.OFTReal))
layer.CreateField(ogr.FieldDefn('XLAT', ogr.OFTReal))
layer.CreateField(ogr.FieldDefn('AREA(km2)', ogr.OFTReal))
defn = layer.GetLayerDefn()

## If there are multiple geometries, put the "for" loop here
for i in range(0,len(geometry)):
    # Create a new feature (attribute and geometry)
    feat = ogr.Feature(defn)
    feat.SetField('id', i)
    poly = geometry[i]
    feat.SetField('XLONG', lon1d[i])   # center
    feat.SetField('XLAT', lat1d[i])   # center
    geometer = transform(m,poly) # geometry in meter projected on the basemap
    feat.SetField('AREA(km2)', geometer.area/1000000)

    # Make a geometry, from Shapely object
    geom = ogr.CreateGeometryFromWkb(poly.wkb)
    feat.SetGeometry(geom)
    layer.CreateFeature(feat)
    feat = geom = None  # destroy these
# Save and close everything
ds = layer = feat = geom = feat1 = geom1 = None

# Define the projection of the CMAQ shapefile
f = open(cmaqname+'.prj','w')
f.write('GEOGCS["GCS_WGS_1984",DATUM["D_WGS_1984",SPHEROID["WGS_1984",6378137.0,298.257223563]],PRIMEM["Greenwich",0.0],UNIT["Degree",0.0174532925199433]]')
f.close()

g1 = gpd.GeoDataFrame.from_file('../../input/airshp/airportiatashape.shp') # emission file
file='../../output/allemis.csv'
dcnect=pd.read_csv(file,encoding='gbk')
tmp=pd.merge(g1,dcnect,on=['IATA'],how='left')
g1=tmp
geomemis = g1['geometry']

gpm25=g1.PM25.copy()
gso2=g1.SO2.copy()
gnox=g1.NOx.copy()
ghc=g1.HC.copy()
gco=g1.CO.copy()
gco2=g1.CO2.copy()

for g in range(0,len(geomemis)):
    polg = geomemis[g]
    geomg = transform(m,polg)

    g1.PM25[g] =gpm25[g]/geomg.area*1000000
    g1.SO2[g]=gso2[g]/geomg.area*1000000
    g1.NOx[g]=gnox[g]/geomg.area*1000000
    g1.HC[g]=ghc[g]/geomg.area*1000000
    g1.CO[g] =gco[g]/geomg.area*1000000
    g1.CO2[g] =gco2[g]/geomg.area*1000000

g2 = gpd.GeoDataFrame.from_file(cmaqname+".shp") # cmaq domain 
geomcmaq = g2['geometry']             

#intersect version 2
idx = index.Index()
print("           Populate R-tree index with bounds of the emission grid cells")
for pos, cell in enumerate(geomemis):
	# assuming cell is a shapely object
	idx.insert(pos, cell.bounds)
data = []

print("           Loop through each Shapely model polygons")
for i,poly in enumerate(geomcmaq):
	datacel = []
	emisarea = transform(m,poly) # geometry in meter projected on the basemap
	for pos in idx.intersection(poly.bounds):
		emideg = poly.intersection(geomemis[pos])
		emimet = transform(m,emideg)
		datacel.append( {'geometry': poly, 'country': g1.O_Name[pos], 'IATA': g1.IATA[pos], 'pm25': g1.PM25[pos]*(emimet.area/1000000),'so2': g1.SO2[pos]*(emimet.area/1000000), 'nox': g1.NOx[pos]*(emimet.area/1000000), 'hc': g1.HC[pos]*(emimet.area/1000000), 'co': g1.CO[pos]*(emimet.area/1000000),'co2': g1.CO2[pos]*(emimet.area/1000000),'units': 'g' })
	PAYS = []
	for dd in range(0,len(datacel)):
		PAYS.append(datacel[dd]['country'])
	PAYS = list(set(PAYS)) # list occurence of countries crossing the CMAQ cell

	if (PAYS == []):
		NOC = 'NO COUNTRY'
		data.append( {'geometry': poly, 'country': 'none', 'IATA': 'none', 'lon': g2.XLONG[i], 'lat': g2.XLAT[i], 'so2':0.0, 'nox':0.0 , 'hc':0.0, 'co':0.0 , 'pm25':0.0, 'co2':0.0 ,'units': 'g', 'area': emisarea.area/1000000 })
	else:
		for dd in PAYS:            
			datared = datacel
			emi_pm25 = 0
			emi_nox = 0
			emi_hc = 0
			emi_co  = 0
			emi_so2 = 0
			emi_co2 = 0
			CC = datared[0]['country']
			YY = datared[0]['IATA']
			UU = datared[0]['units']
			for ddi in range(0,len(datared)):
				emi_so2 = emi_so2 + datared[ddi]['so2']  # g
				emi_nox = emi_nox + datared[ddi]['nox']  # g
				emi_hc = emi_hc + datared[ddi]['hc']  # g
				emi_co  = emi_co  + datared[ddi]['co']   # g
				emi_pm25 = emi_pm25 + datared[ddi]['pm25']  # g
				emi_co2 = emi_co2 + datared[ddi]['co2']  # g
			data.append( {'geometry': poly, 'country': CC, 'IATA': YY, 'lon': g2.XLONG[i], 'lat': g2.XLAT[i], 'so2': emi_so2, 'nox': emi_nox, 'hc': emi_hc, 'co': emi_co, 'pm25': emi_pm25,'co2': emi_co2 , 'units': 'g', 'area': emisarea.area/1000000 })

print('           Write to shapefile')
df = gpd.GeoDataFrame(data,columns=['geometry','country','IATA','lon','lat','so2','nox','hc','co','pm25','co2','units','area'])
df.to_file('EMIS_'+cmaqname+'.shp')    
f = open('EMIS_'+cmaqname+'.prj','w')
f.write('GEOGCS["GCS_WGS_1984",DATUM["D_WGS_1984",SPHEROID["WGS_1984",6378137.0,298.257223563]],PRIMEM["Greenwich",0.0],UNIT["Degree",0.0174532925199433]]')
f.close()

print('           Write to ASCII')
outdir='./'+domain
if not os.path.exists(outdir):
   os.makedirs(outdir)
nom = outdir+'/emis.csv'
dfcsv=pd.DataFrame({'lon':df['lon'],'lat':df['lat'],'IATA':df['IATA'],'so2':df['so2'],'nox':df['nox'],'hc':df['hc'],'co':df['co'],'pm25':df['pm25'],'co2':df['co2'],'units':df['units'],'area':df['area']})    #area km2 
dfcsv.to_csv(nom,mode='w',encoding='utf-8-sig' ,sep=',',index=0) 
print('           Successful.')
