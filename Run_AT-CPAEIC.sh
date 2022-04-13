#!/bin/bash

workdir=$(pwd)

#echo "0. get flight data ..."
#cd ${workdir}/core/getdata
#python get_flight_data.py 

echo "1.filght data pre-process ..."
cd ${workdir}/core/preproc
python process_flight_data.py

echo "2.emission calculation ..."
cd ${workdir}/core/calemis
rm *.exe
gfortran -o calarrive.exe calarrive.f90
gfortran -o caldepart.exe caldepart.f90
./calarrive.exe
./caldepart.exe
python combine_emis.py

echo "3.spatial allocation ..."
cd ${workdir}/core/intersect
python emission2modelgrid.py d01

echo "4. temporal allocation and speciation mapping ..."
echo "5. write emission file : ARemis.nc "
cd ${workdir}/core/writenc
python area_emis_process.py
echo "The result is in ${workdir}/output"
echo "Successful."

