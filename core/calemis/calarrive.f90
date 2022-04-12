		Program end
		implicit none
		character(6),allocatable,Dimension(:)::airtype,airportcode
		character(20),allocatable,Dimension(:)::time
		integer i,s,w,GetFileN
                character(len=34)::line1 = "IATA,&
                &HC,CO,NOx,PM25,SO2,CO2"

		real c
		integer,allocatable,Dimension(:)::rNpd,rRa,rATM,rnum,rNATSGRP
		real,allocatable,Dimension(:)::rPR,rSNmax,HCa,HCb,HCc,HCd,COa,COb, & 
		& COc,COd,NOxa,NOxb,NOxc,NOxd,fuelflowa,fuelflowb,fuelflowc,fuelflowd
		real,allocatable,Dimension(:)::Timapp,Timlan,Timtin,Timhol,Timtak, &
		& Timini,Timcli,Timtou

		!中间变量
		real,allocatable,Dimension(:)::REIBCa,REIBCb,REIBCc,REIBCd
		real,allocatable,Dimension(:)::thrapp,thrtak,thrini,thrcli,thrlan, & 
		& thrtin,thrtou,thrhol

		!新增排放因子
		real,allocatable,Dimension(:)::EIBCa,EIBCb,EIBCc,EIBCd,EIBCe, & 
		& EIBCf,EIBCg,EIBCh
		real,allocatable,Dimension(:)::EIOCa,EIOCb,EIOCc,EIOCd,EIOCe, & 
		& EIOCf,EIOCg,EIOCh
		real,allocatable,Dimension(:)::EIPMa,EIPMb,EIPMc,EIPMd,EIPMe, & 
		& EIPMf,EIPMg,EIPMh

		!输出排放量
		real,allocatable,Dimension(:)::EHCa,EHCb,EHCc,EHCd,EHCe,EHCf,EHCg,EHCh
		real,allocatable,Dimension(:)::ECOa,ECOb,ECOc,ECOd,ECOe,ECOf,ECOg,ECOh
		real,allocatable,Dimension(:)::ENOxa,ENOxb,ENOxc,ENOxd,ENOxe, & 
		& ENOxf,ENOxg,ENOxh
		real,allocatable,Dimension(:)::EBCa,EBCb,EBCc,EBCd,EBCe,EBCf,EBCg,EBCh
		real,allocatable,Dimension(:)::EOCa,EOCb,EOCc,EOCd,EOCe,EOCf,EOCg,EOCh
		real,allocatable,Dimension(:)::ESO4a,ESO4b,ESO4c,ESO4d,ESO4e, & 
		& ESO4f,ESO4g,ESO4h
		real,allocatable,Dimension(:)::EPMa,EPMb,EPMc,EPMd,EPMe,EPMf,EPMg,EPMh
		real,allocatable,Dimension(:)::ESO2a,ESO2b,ESO2c,ESO2d,ESO2e, & 
		& ESO2f,ESO2g,ESO2h
		real,allocatable,Dimension(:)::ECO2a,ECO2b,ECO2c,ECO2d,ECO2e, & 
		& ECO2f,ECO2g,ECO2h


		real:: my_random
		real:: lboundi,uboundi
		real::Q2,P2,Q1,p1,kt,bt,midm
		real::p11,p22,Q11,Q22,ktt,btt,midme
		Real::FSC=600,Eps=0.02,MW_SO2=64,MW_SO4=96,MW_S=32

		real SO4,SO2,CO2


		character(6)::airportB(233),airportA(233)
		real THCa(233),THCb(233),THCc(233),THCd(233),THCe(233)
		real TCOa(233),TCOb(233),TCOc(233),TCOd(233),TCOe(233)
		real TNOxa(233),TNOxb(233),TNOxc(233),TNOxd(233),TNOxe(233)
		real TBCa(233),TBCb(233),TBCc(233),TBCd(233),TBCe(233)
		real TOCa(233),TOCb(233),TOCc(233),TOCd(233),TOCe(233)
		real TSO4a(233),TSO4b(233),TSO4c(233),TSO4d(233),TSO4e(233)
		real TPMa(233),TPMb(233),TPMc(233),TPMd(233),TPMe(233)
		real TSO2a(233),TSO2b(233),TSO2c(233),TSO2d(233),TSO2e(233)
		real TCO2a(233),TCO2b(233),TCO2c(233),TCO2d(233),TCO2e(233)

		real HCarr(233),COarr(233),NOxarr(233),PMarr(233),SO2arr(233),CO2arr(233)

                CHARACTER(LEN=50),PARAMETER :: arrivefile='../../output/tmp/out_arrivedata.csv'
		CHARACTER(LEN=50),PARAMETER :: pdfile='../../input/pd.csv'
		CHARACTER(LEN=50),PARAMETER :: arriveoutfile='../../output/tmp/aemis.csv'

		!20储存数组大小，21储存出发输入值,22机场三字码，24输出
		!open(20,file=)
		open(21,file=arrivefile)
		open(22,file=pdfile)
		open(23,file=arriveoutfile)


		s=GetFileN(21)

		DO i=1,233
		read(22,*)airportB(i)
		END DO

		!分配动态数组大小  
		allocate(airtype(s),airportcode(s),time(s),rNpd(s),rRa(s),rATM(s), & 
		& rnum(s),rNATSGRP(s),rPR(s),rSNmax(s),HCa(s),HCb(s), & 
		& HCc(s),HCd(s),COa(s),COb(s),COc(s),COd(s), &
		& NOxa(s),NOxb(s),NOxc(s),NOxd(s),fuelflowa(s),fuelflowb(s), & 
		& fuelflowc(s),fuelflowd(s),Timapp(s),Timlan(s), & 
		& Timtin(s),Timhol(s),Timtak(s),Timini(s),Timcli(s),Timtou(s))

		!读输入值 
		Do i=1,s
		read(21,*)airtype(i),airportcode(i),rNpd(i),rRa(i), &
		& rATM(i),rnum(i),rNATSGRP(i),rPR(i),rSNmax(i),HCa(i), &
		& HCb(i),HCc(i),HCd(i),&
		& COa(i),COb(i),COc(i),COd(i),NOxa(i),NOxb(i),NOxc(i),NOxd(i), &
		& fuelflowa(i),fuelflowb(i),fuelflowc(i),fuelflowd(i)


		!print*,airtype(i),airportcode(i),rNpd(i),rRa(i), &
		! & rATM(i),rnum(i),rNATSGRP(i),rPR(i),rSNmax(i),HCa(i), &
		! & HCb(i),HCc(i),HCd(i), &
		! & COa(i),COb(i),COc(i),COd(i),NOxa(i),NOxb(i),NOxc(i),NOxd(i), &
		! & fuelflowa(i),fuelflowb(i),fuelflowc(i),fuelflowd(i)
		END DO
		DO w=1,s
		Select case(rNATSGRP(w))

		case(1)
		Timapp(w)=286.0
		Timtak(w)=44.6      
		Timini(w)=57.0
		Timcli(w)=77.6
		Timlan(w)=70.0
		case(2)
		Timapp(w)=286.0
		Timtak(w)=32.6
		Timini(w)=41.7
		Timcli(w)=57.7
		Timlan(w)=70.0
		case(3)
		Timapp(w)=286.0
		Timtak(w)=38.1
		Timini(w)=85.0
		Timcli(w)=120
		Timlan(w)=70.0
		case(4)
		Timapp(w)=286.0
		Timtak(w)=28.7
		Timini(w)=33.0
		Timcli(w)=48.5
		Timlan(w)=60.0
		case(5:7)
		Timapp(w)=286.0
		Timtak(w)=29.5
		Timini(w)=38.0
		Timcli(w)=61.1
		Timlan(w)=60.0
		case(8)
		Timapp(w)=286.0
		Timtak(w)=26.3
		Timini(w)=50.0
		Timcli(w)=80.0
		Timlan(w)=60.0
		case(9:12)
		Timapp(w)=312.0
		Timtak(w)=28.0
		Timini(w)=90.0
		Timcli(w)=120.0
		Timlan(w)=60.0
		END select
		Timtin(w)=0.1*rRa(w)
		Timtou(w)=Timtin(w)
		c=rATM(w)/rNpd(w)
		IF(c<100000.0)THEN
		Timhol(w)=0.0
		Else IF(c>400000.0)THEN
		Timhol(w)=600.0
		ELse
		Timhol(w)=0.02*(c-100000.0)
		END IF
		END DO					



		!分配中间变量数组大小
		allocate(REIBCa(s),REIBCb(s),REIBCc(s),REIBCd(s))
		allocate(thrapp(s),thrtak(s),thrini(s),thrcli(s),thrlan(s), &
		& thrtin(s),thrtou(s),thrhol(s))

		DO w=1,s
		IF(NOxa(w)==0.0000)NOxa(w)=0.00001
		IF(NOxb(w)==0.0000)NOxb(w)=0.00001
		IF(NOxc(w)==0.0000)NOxc(w)=0.00001
		IF(NOxd(w)==0.0000)NOxd(w)=0.00001
		IF(COa(w)==0.0000)COa(w)=0.00001
		IF(COb(w)==0.0000)COb(w)=0.00001
		IF(COc(w)==0.0000)COc(w)=0.00001
		IF(COd(w)==0.0000)COd(w)=0.00001

		REIBCa(w)=4.57*0.001*(NOxa(w)/4)**(-1.27)*(COa(w)/20)**(-0.4)* & 
		& (rSNmax(w)/10)**(0.2)*(rPR(w)*0.07)**(1.25)
		REIBCb(w)=4.57*0.001*(NOxb(w)/7)**(-1.27)*(COb(w)/5)**(-0.4)* & 
		& (rSNmax(w)/10)**(0.2)*(rPR(w)*0.30)**(1.25)
		REIBCc(w)=4.57*0.001*(NOxc(w)/20)**(-1.27)*(COc(w)/1)**(-0.4)* & 
		& (rSNmax(w)/10)**(0.2)*(rPR(w)*0.85)**(1.25)
		REIBCd(w)=4.57*0.001*(NOxd(w)/25)**(-1.27)*(COd(w)/1)**(-0.4)* & 
		& (rSNmax(w)/10)**(0.2)*(rPR(w)*1.0)**(1.25)

		IF(REIBCa(w)==0.0000)REIBCa(w)=0.00001
		IF(REIBCb(w)==0.0000)REIBCb(w)=0.00001
		IF(REIBCc(w)==0.0000)REIBCc(w)=0.00001
		IF(REIBCd(w)==0.0000)REIBCd(w)=0.00001

		END DO


		!分配新排放因子数组大小
		allocate(EIBCa(s),EIBCb(s),EIBCc(s),EIBCd(s),EIBCe(s), & 
		& EIBCf(s),EIBCg(s),EIBCh(s))
		allocate(EIOCa(s),EIOCb(s),EIOCc(s),EIOCd(s),EIOCe(s), & 
		& EIOCf(s),EIOCg(s),EIOCh(s))

		DO w=1,s

		call random_seed()
		thrapp(w)=my_random(0.21,0.30)
		thrtak(w)=my_random(0.75,1.00)
		thrini(w)=my_random(0.75,1.00)
		thrcli(w)=my_random(0.75,0.85)
		thrlan(w)=my_random(0.04,0.07)
		thrtin(w)=my_random(0.04,0.07)
		thrtou(w)=my_random(0.04,0.07)
		thrhol(w)=my_random(0.04,0.07)
		!real Q2,P2,Q1,p1,kt,bt,midm
		Q2=LOG10(REIBCb(w))
		P2=LOG10(0.3)
		Q1=LOG10(REIBCa(w))
		P1=LOG10(0.07)
		kt=((Q2-Q1)/(P2-P1))
		bt=Q1-kt*P1
		midm=kt*log10(thrapp(w))+bt
		EIBCa(w)=10**midm

		midm=kt*log10(thrlan(w))+bt
		EIBCe(w)=10**midm

		midm=kt*log10(thrtin(w))+bt
		EIBCf(w)=10**midm

		midm=kt*log10(thrtou(w))+bt
		EIBCg(w)=10**midm

		midm=kt*log10(thrhol(w))+bt
		EIBCh(w)=10**midm

		IF      (thrtak(w)<=0.85) then
		Q2=LOG10(REIBCc(w))
		P2=LOG10(0.85)
		Q1=LOG10(REIBCb(w))
		P1=LOG10(0.3)
		kt=((Q2-Q1)/(P2-P1))
		bt=Q1-kt*P1
		midm=kt*log10(thrtak(w))+bt
		EIBCb(w)=10**midm
		ELSE 
		Q2=LOG10(REIBCd(w))
		P2=LOG10(1.00)
		Q1=LOG10(REIBCc(w))
		P1=LOG10(0.85)
		kt=((Q2-Q1)/(P2-P1))
		bt=Q1-kt*P1
		midm=kt*log10(thrtak(w))+bt
		EIBCb(w)=10**midm
		END IF
		IF      (thrini(w)<=0.85) then
		Q2=LOG10(REIBCc(w))
		P2=LOG10(0.85)
		Q1=LOG10(REIBCb(w))
		P1=LOG10(0.3)
		kt=((Q2-Q1)/(P2-P1))
		bt=Q1-kt*P1
		midm=kt*log10(thrini(w))+bt
		EIBCc(w)=10**midm
		ELSE 
		Q2=LOG10(REIBCd(w))
		P2=LOG10(1.00)
		Q1=LOG10(REIBCc(w))
		P1=LOG10(0.85)
		kt=((Q2-Q1)/(P2-P1))
		bt=Q1-kt*P1
		midm=kt*log10(thrini(w))+bt
		EIBCc(w)=10**midm
		END IF

		Q2=LOG10(REIBCc(w))
		P2=LOG10(0.85)
		Q1=LOG10(REIBCb(w))
		P1=LOG10(0.3)
		kt=((Q2-Q1)/(P2-P1))
		bt=Q1-kt*P1
		midm=kt*log10(thrcli(w))+bt
		EIBCd(w)=10**midm 

		!NaN
		IF(EIBCa(w)==0.0000)EIBCa(w)=0.00001
		IF(EIBCb(w)==0.0000)EIBCb(w)=0.00001
		IF(EIBCc(w)==0.0000)EIBCc(w)=0.00001
		IF(EIBCd(w)==0.0000)EIBCd(w)=0.00001 
		IF(EIBCe(w)==0.0000)EIBCe(w)=0.00001
		IF(EIBCf(w)==0.0000)EIBCf(w)=0.00001
		IF(EIBCg(w)==0.0000)EIBCg(w)=0.00001
		IF(EIBCh(w)==0.0000)EIBCh(w)=0.00001 

		EIOCe(w)=6.17*HCa(w)*0.001
		EIOCf(w)=6.17*HCa(w)*0.001
		EIOCg(w)=6.17*HCa(w)*0.001
		EIOCh(w)=6.17*HCa(w)*0.001

		Q22=LOG10(56.25)
		P22=LOG10(0.3)
		Q11=LOG10(6.17)
		P11=LOG10(0.07)
		ktt=((Q22-Q11)/(P22-P11))
		btt=Q11-ktt*P11
		midme=ktt*log10(thrapp(w))+btt
		EIOCa(w)=10**midme*HCb(w)*0.001



		IF      (thrtak(w)<=0.85) then
		Q22=LOG10(76.0)
		P22=LOG10(0.85)
		Q11=LOG10(56.25)
		P11=LOG10(0.3)
		ktt=((Q22-Q11)/(P22-P11))
		btt=Q11-ktt*P11
		midme=ktt*log10(thrtak(w))+btt
		EIOCb(w)=10**midme*HCd(w)*0.001
		ELSE 
		Q22=LOG10(115.0)
		P22=LOG10(1.00)
		Q11=LOG10(76.0)
		P11=LOG10(0.85)
		ktt=((Q22-Q11)/(P22-P11))
		btt=Q11-ktt*P11
		midme=ktt*log10(thrtak(w))+btt
		EIOCb(w)=10**midme*HCd(w)*0.001
		END IF

		IF      (thrini(w)<=0.85) then
		Q22=LOG10(76.0)
		P22=LOG10(0.85)
		Q11=LOG10(56.25)
		P11=LOG10(0.3)
		ktt=((Q22-Q11)/(P22-P11))
		btt=Q11-ktt*P11
		midme=ktt*log10(thrini(w))+btt
		EIOCc(w)=10**midme*HCd(w)*0.001
		ELSE 
		Q22=LOG10(115.0)
		P22=LOG10(1.00)
		Q11=LOG10(76.0)
		P11=LOG10(0.85)
		ktt=((Q22-Q11)/(P22-P11))
		btt=Q11-ktt*P11
		midme=ktt*log10(thrini(w))+btt
		EIOCc(w)=10**midme*HCd(w)*0.001
		END IF
		Q22=LOG10(76.0)
		P22=LOG10(0.85)
		Q11=LOG10(56.25)
		P11=LOG10(0.3)
		ktt=((Q22-Q11)/(P22-P11))
		btt=Q11-ktt*P11
		midme=ktt*log10(thrcli(w))+btt
		EIOCd(w)=10**midme*HCc(w)*0.001
		END DO	  

		FSC=680
		SO4=FSC/1000*Eps*MW_SO4/MW_S 
		SO2=FSC/1000*(1-Eps)*MW_SO2/MW_S 
		CO2=3150

		allocate(EIPMa(s),EIPMb(s),EIPMc(s),EIPMd(s),EIPMe(s), & 
		& EIPMf(s),EIPMg(s),EIPMh(s))

		DO w=1,s
		EIPMa(w)=SO4+EIBCa(w)+EIOCa(w)
		EIPMb(w)=SO4+EIBCb(w)+EIOCb(w)
		EIPMc(w)=SO4+EIBCc(w)+EIOCc(w)
		EIPMd(w)=SO4+EIBCd(w)+EIOCd(w)
		EIPMe(w)=SO4+EIBCe(w)+EIOCe(w)
		EIPMf(w)=SO4+EIBCf(w)+EIOCf(w)
		EIPMg(w)=SO4+EIBCg(w)+EIOCg(w)
		EIPMh(w)=SO4+EIBCh(w)+EIOCh(w)
		END DO	  

		allocate(EHCa(s),EHCb(s),EHCc(s),EHCd(s),EHCe(s),EHCf(s), & 
		& EHCg(s),EHCh(s))
		allocate(ECOa(s),ECOb(s),ECOc(s),ECOd(s),ECOe(s),ECOf(s), & 
		& ECOg(s),ECOh(s))
		allocate(ENOxa(s),ENOxb(s),ENOxc(s),ENOxd(s),ENOxe(s),ENOxf(s), & 
		& ENOxg(s),ENOxh(s))
		allocate(EBCa(s),EBCb(s),EBCc(s),EBCd(s),EBCe(s),EBCf(s), & 
		& EBCg(s),EBCh(s))
		allocate(EOCa(s),EOCb(s),EOCc(s),EOCd(s),EOCe(s),EOCf(s), &
		& EOCg(s),EOCh(s))
		allocate(ESO4a(s),ESO4b(s),ESO4c(s),ESO4d(s),ESO4e(s), & 
		& ESO4f(s),ESO4g(s),ESO4h(s))
		allocate(EPMa(s),EPMb(s),EPMc(s),EPMd(s),EPMe(s), & 
		& EPMf(s),EPMg(s),EPMh(s))
		allocate(ESO2a(s),ESO2b(s),ESO2c(s),ESO2d(s),ESO2e(s), & 
		& ESO2f(s),ESO2g(s),ESO2h(s))
		allocate(ECO2a(s),ECO2b(s),ECO2c(s),ECO2d(s),ECO2e(s), & 
		& ECO2f(s),ECO2g(s),ECO2h(s))


		DO w=1,s
		EHCa(w)=HCb(w)*fuelflowb(w)*Timapp(w)*rnum(w)*0.001
		EHCb(w)=HCd(w)*fuelflowd(w)*Timtak(w)*rnum(w)*0.001
		EHCc(w)=HCd(w)*fuelflowd(w)*Timini(w)*rnum(w)*0.001
		EHCd(w)=HCc(w)*fuelflowc(w)*Timcli(w)*rnum(w)*0.001
		EHCe(w)=HCa(w)*fuelflowa(w)*Timlan(w)*rnum(w)*0.001
		EHCf(w)=HCa(w)*fuelflowa(w)*Timtin(w)*rnum(w)*0.001
		EHCg(w)=HCa(w)*fuelflowa(w)*Timtou(w)*rnum(w)*0.001
		EHCh(w)=HCa(w)*fuelflowa(w)*Timhol(w)*rnum(w)*0.5*0.001

		ECOa(w)=COb(w)*fuelflowb(w)*Timapp(w)*rnum(w)*0.001
		ECOb(w)=COd(w)*fuelflowd(w)*Timtak(w)*rnum(w)*0.001
		ECOc(w)=COd(w)*fuelflowd(w)*Timini(w)*rnum(w)*0.001
		ECOd(w)=COc(w)*fuelflowc(w)*Timcli(w)*rnum(w)*0.001
		ECOe(w)=COa(w)*fuelflowa(w)*Timlan(w)*rnum(w)*0.001
		ECOf(w)=COa(w)*fuelflowa(w)*Timtin(w)*rnum(w)*0.001
		ECOg(w)=COa(w)*fuelflowa(w)*Timtou(w)*rnum(w)*0.001
		ECOh(w)=COa(w)*fuelflowa(w)*Timhol(w)*rnum(w)*0.5*0.001

		ENOxa(w)=NOxb(w)*fuelflowb(w)*Timapp(w)*rnum(w)*0.001
		ENOxb(w)=NOxd(w)*fuelflowd(w)*Timtak(w)*rnum(w)*0.001
		ENOxc(w)=NOxd(w)*fuelflowd(w)*Timini(w)*rnum(w)*0.001
		ENOxd(w)=NOxc(w)*fuelflowc(w)*Timcli(w)*rnum(w)*0.001
		ENOxe(w)=NOxa(w)*fuelflowa(w)*Timlan(w)*rnum(w)*0.001
		ENOxf(w)=NOxa(w)*fuelflowa(w)*Timtin(w)*rnum(w)*0.001
		ENOxg(w)=NOxa(w)*fuelflowa(w)*Timtou(w)*rnum(w)*0.001
		ENOxh(w)=NOxa(w)*fuelflowa(w)*Timhol(w)*rnum(w)*0.5*0.001

		EBCa(w)=EIBCa(w)*fuelflowb(w)*Timapp(w)*rnum(w)*0.001
		EBCb(w)=EIBCb(w)*fuelflowd(w)*Timtak(w)*rnum(w)*0.001
		EBCc(w)=EIBCc(w)*fuelflowd(w)*Timini(w)*rnum(w)*0.001
		EBCd(w)=EIBCd(w)*fuelflowc(w)*Timcli(w)*rnum(w)*0.001
		EBCe(w)=EIBCe(w)*fuelflowa(w)*Timlan(w)*rnum(w)*0.001
		EBCf(w)=EIBCf(w)*fuelflowa(w)*Timtin(w)*rnum(w)*0.001
		EBCg(w)=EIBCg(w)*fuelflowa(w)*Timtou(w)*rnum(w)*0.001
		EBCh(w)=EIBCh(w)*fuelflowa(w)*Timhol(w)*rnum(w)*0.5*0.001


		EOCa(w)=EIOCa(w)*fuelflowb(w)*Timapp(w)*rnum(w)*0.001
		EOCb(w)=EIOCb(w)*fuelflowd(w)*Timtak(w)*rnum(w)*0.001
		EOCc(w)=EIOCc(w)*fuelflowd(w)*Timini(w)*rnum(w)*0.001
		EOCd(w)=EIOCd(w)*fuelflowc(w)*Timcli(w)*rnum(w)*0.001
		EOCe(w)=EIOCe(w)*fuelflowa(w)*Timlan(w)*rnum(w)*0.001
		EOCf(w)=EIOCf(w)*fuelflowa(w)*Timtin(w)*rnum(w)*0.001
		EOCg(w)=EIOCg(w)*fuelflowa(w)*Timtou(w)*rnum(w)*0.001
		EOCh(w)=EIOCh(w)*fuelflowa(w)*Timhol(w)*rnum(w)*0.5*0.001



		ESO4a(w)=SO4*fuelflowb(w)*Timapp(w)*rnum(w)*0.001
		ESO4b(w)=SO4*fuelflowd(w)*Timtak(w)*rnum(w)*0.001
		ESO4c(w)=SO4*fuelflowd(w)*Timini(w)*rnum(w)*0.001
		ESO4d(w)=SO4*fuelflowc(w)*Timcli(w)*rnum(w)*0.001
		ESO4e(w)=SO4*fuelflowa(w)*Timlan(w)*rnum(w)*0.001
		ESO4f(w)=SO4*fuelflowa(w)*Timtin(w)*rnum(w)*0.001
		ESO4g(w)=SO4*fuelflowa(w)*Timtou(w)*rnum(w)*0.001
		ESO4h(w)=SO4*fuelflowa(w)*Timhol(w)*rnum(w)*0.5*0.001


		EPMa(w)=EIPMa(w)*fuelflowb(w)*Timapp(w)*rnum(w)*0.001
		EPMb(w)=EIPMb(w)*fuelflowd(w)*Timtak(w)*rnum(w)*0.001
		EPMc(w)=EIPMc(w)*fuelflowd(w)*Timini(w)*rnum(w)*0.001
		EPMd(w)=EIPMd(w)*fuelflowc(w)*Timcli(w)*rnum(w)*0.001
		EPMe(w)=EIPMe(w)*fuelflowa(w)*Timlan(w)*rnum(w)*0.001
		EPMf(w)=EIPMf(w)*fuelflowa(w)*Timtin(w)*rnum(w)*0.001
		EPMg(w)=EIPMg(w)*fuelflowa(w)*Timtou(w)*rnum(w)*0.001
		EPMh(w)=EIPMh(w)*fuelflowa(w)*Timhol(w)*rnum(w)*0.5*0.001


		ESO2a(w)=SO2*fuelflowb(w)*Timapp(w)*rnum(w)*0.001
		ESO2b(w)=SO2*fuelflowd(w)*Timtak(w)*rnum(w)*0.001
		ESO2c(w)=SO2*fuelflowd(w)*Timini(w)*rnum(w)*0.001
		ESO2d(w)=SO2*fuelflowc(w)*Timcli(w)*rnum(w)*0.001
		ESO2e(w)=SO2*fuelflowa(w)*Timlan(w)*rnum(w)*0.001
		ESO2f(w)=SO2*fuelflowa(w)*Timtin(w)*rnum(w)*0.001
		ESO2g(w)=SO2*fuelflowa(w)*Timtou(w)*rnum(w)*0.001
		ESO2h(w)=SO2*fuelflowa(w)*Timhol(w)*rnum(w)*0.5*0.001

		ECO2a(w)=CO2*fuelflowb(w)*Timapp(w)*rnum(w)*0.001
		ECO2b(w)=CO2*fuelflowd(w)*Timtak(w)*rnum(w)*0.001
		ECO2c(w)=CO2*fuelflowd(w)*Timini(w)*rnum(w)*0.001
		ECO2d(w)=CO2*fuelflowc(w)*Timcli(w)*rnum(w)*0.001
		ECO2e(w)=CO2*fuelflowa(w)*Timlan(w)*rnum(w)*0.001
		ECO2f(w)=CO2*fuelflowa(w)*Timtin(w)*rnum(w)*0.001
		ECO2g(w)=CO2*fuelflowa(w)*Timtou(w)*rnum(w)*0.001
		ECO2h(w)=CO2*fuelflowa(w)*Timhol(w)*rnum(w)*0.5*0.001


		END DO
		!DO i=1,3
		!write(24,*) EHCa,EHCb,EHCc,EHCd,EHCe,EHCf,EHCg,EHCh,ECOa,ECOb,ECOc,ECOd, &
		!& ECOe,ECOf,ECOg,ECOh,ENOxa,ENOxb,ENOxc,ENOxd,ENOxe, &
		!& ENOxf,ENOxg,ENOxh,EBCa,EBCb,EBCc,EBCd,EBCe,EBCf,EBCg, &
		!& EBCh,EOCa,EOCb,EOCc,EOCd,EOCe,EOCf,EOCg,EOCh,ESO4a,ESO4b, &
		!& ESO4c,ESO4d,ESO4e,ESO4f,ESO4g,ESO4h,EPMa,EPMb,EPMc, &
		!& EPMd,EPMe,EPMf,EPMg,EPMh, &
		!& ESO2a,ESO2b,ESO2c,ESO2d,ESO2e,ESO2f,ESO2g,ESO2h,ECO2a,&
		!& ECO2b,ECO2c,ECO2d,ECO2e,ECO2f,ECO2g,ECO2h               

		!End do


		Do i=1,233
			 THCa(i)=0.0
			 THCb(i)=0.0
			 THCc(i)=0.0
			 THCd(i)=0.0
			 
			 TCOa(i)=0.0
			 TCOb(i)=0.0
			 TCOc(i)=0.0
			 TCOd(i)=0.0
			
			 TNOxa(i)=0.0
			 TNOxb(i)=0.0
			 TNOxc(i)=0.0
			 TNOxd(i)=0.0
			 
			 TBCa(i)=0.0
			 TBCb(i)=0.0
			 TBCc(i)=0.0
			 TBCd(i)=0.0
			 
			 TOCa(i)=0.0
			 TOCb(i)=0.0
			 TOCc(i)=0.0
			 TOCd(i)=0.0
			
			 TSO4a(i)=0.0
			 TSO4b(i)=0.0
			 TSO4c(i)=0.0
			 TSO4d(i)=0.0
			
			 TPMa(i)=0.0
			 TPMb(i)=0.0
			 TPMc(i)=0.0
			 TPMd(i)=0.0
			
			 TSO2a(i)=0.0
			 TSO2b(i)=0.0
			 TSO2c(i)=0.0
			 TSO2d(i)=0.0
			
			 TCO2a(i)=0.0
			 TCO2b(i)=0.0
			 TCO2c(i)=0.0
			 TCO2d(i)=0.0
			 
		  DO w=1,S
			 If(airportcode(w)==airportB(i))THCa(i)=THCa(i)+EHCa(w)
			 If(airportcode(w)==airportB(i))THCb(i)=THCb(i)+EHCe(w) 
			 If(airportcode(w)==airportB(i))THCc(i)=THCc(i)+EHCf(w)
			 If(airportcode(w)==airportB(i))THCd(i)=THCd(i)+EHCh(w)
			 
					  
			 If(airportcode(w)==airportB(i))TCOa(i)=TCOa(i)+ECOa(w)
			 If(airportcode(w)==airportB(i))TCOb(i)=TCOb(i)+ECOe(w) 
			 If(airportcode(w)==airportB(i))TCOc(i)=TCOc(i)+ECOf(w)
			 If(airportcode(w)==airportB(i))TCOd(i)=TCOd(i)+ECOh(w)
			 


			 If(airportcode(w)==airportB(i))TNOxa(i)=TNOxa(i)+ENOxa(w)
			 If(airportcode(w)==airportB(i))TNOxb(i)=TNOxb(i)+ENOxe(w) 
			 If(airportcode(w)==airportB(i))TNOxc(i)=TNOxc(i)+ENOxf(w)
			 If(airportcode(w)==airportB(i))TNOxd(i)=TNOxd(i)+ENOxh(w)
			 

			 If(airportcode(w)==airportB(i))TBCa(i)=TBCa(i)+EBCa(w)
			 If(airportcode(w)==airportB(i))TBCb(i)=TBCb(i)+EBCe(w) 
			 If(airportcode(w)==airportB(i))TBCc(i)=TBCc(i)+EBCf(w)
			 If(airportcode(w)==airportB(i))TBCd(i)=TBCd(i)+EBCh(w)
			

			 If(airportcode(w)==airportB(i))TOCa(i)=TOCa(i)+EOCa(w)
			 If(airportcode(w)==airportB(i))TOCb(i)=TOCb(i)+EOCe(w) 
			 If(airportcode(w)==airportB(i))TOCc(i)=TOCc(i)+EOCf(w)
			 If(airportcode(w)==airportB(i))TOCd(i)=TOCd(i)+EOCh(w)
			

			 If(airportcode(w)==airportB(i))TSO4a(i)=TSO4a(i)+ESO4a(w)
			 If(airportcode(w)==airportB(i))TSO4b(i)=TSO4b(i)+ESO4e(w) 
			 If(airportcode(w)==airportB(i))TSO4c(i)=TSO4c(i)+ESO4f(w)
			 If(airportcode(w)==airportB(i))TSO4d(i)=TSO4d(i)+ESO4h(w)
			

			 If(airportcode(w)==airportB(i))TPMa(i)=TPMa(i)+EPMa(w)
			 If(airportcode(w)==airportB(i))TPMb(i)=TPMb(i)+EPMe(w) 
			 If(airportcode(w)==airportB(i))TPMc(i)=TPMc(i)+EPMf(w)
			 If(airportcode(w)==airportB(i))TPMd(i)=TPMd(i)+EPMh(w)


			 If(airportcode(w)==airportB(i))TSO2a(i)=TSO2a(i)+ESO2a(w)
			 If(airportcode(w)==airportB(i))TSO2b(i)=TSO2b(i)+ESO2e(w) 
			 If(airportcode(w)==airportB(i))TSO2c(i)=TSO2c(i)+ESO2f(w)
			 If(airportcode(w)==airportB(i))TSO2d(i)=TSO2d(i)+ESO2h(w)
			
			
			 If(airportcode(w)==airportB(i))TCO2a(i)=TCO2a(i)+ECO2a(w)
			 If(airportcode(w)==airportB(i))TCO2b(i)=TCO2b(i)+ECO2e(w) 
			 If(airportcode(w)==airportB(i))TCO2c(i)=TCO2c(i)+ECO2f(w)
			 If(airportcode(w)==airportB(i))TCO2d(i)=TCO2d(i)+ECO2h(w)
			

		  END DO
		END DO
		write(23,'(A)')trim(line1)

		Do w=1,233
		HCarr(w)=THCa(w)+THCb(w)+THCc(w)+THCd(w)
		COarr(w)=TCOa(w)+TCOb(w)+TCOc(w)+TCOd(w)
		NOxarr(w)=TNOxa(w)+TNOxb(w)+TNOxc(w)+ TNOxd(w)
		PMarr(w)=TPMa(w)+TPMb(w)+TPMc(w)+TPMd(w)
		SO2arr(w)=TSO2a(w)+TSO2b(w)+TSO2c(w)+TSO2d(w)
		CO2arr(w)=TCO2a(w)+TCO2b(w)+ TCO2c(w)+TCO2d(w)
		END Do

		Do w=1,233
		write(23,200)airportB(w),HCarr(w),COarr(w),NOxarr(w), &
		& PMarr(w),SO2arr(w),CO2arr(w)
		End Do   
		200 format(A3,',',F23.6,',',F23.6,',',F25.3,',',F22.4,',',F22.3,',',F27.3)

		!close(20)
		close(21)
		close(22)
		close(23)
		!outfile=adjustl(outfile)


		deallocate(airtype,airportcode,time,rNpd,rRa,rATM,rnum,rNATSGRP, &  
		& rPR,rSNmax,HCa,HCb,HCc,HCd,COa,COb,COc,COd,NOxa,NOxb, &
		& NOxc,NOxd,fuelflowa,fuelflowb,fuelflowc, &
		& fuelflowd,Timapp,Timlan,Timtin,Timhol,Timtak,Timini,Timcli, &
		& Timtou,REIBCa,REIBCb,REIBCc,REIBCd,thrapp,thrtak, &
		& thrini,thrcli,thrlan,thrtin,thrtou,thrhol, &
		& EIBCa,EIBCb,EIBCc,EIBCd,EIBCe,EIBCf,EIBCg,EIBCh, &
		& EIOCa,EIOCb,EIOCc,EIOCd,EIOCe,EIOCf,EIOCg,EIOCh,EIPMa, &
		& EIPMb,EIPMc,EIPMd,EIPMe,EIPMf,EIPMg,EIPMh, &
		& EHCa,EHCb,EHCc,EHCd,EHCe,EHCf,EHCg,EHCh,ECOa,ECOb,ECOc,ECOd, &
		& ECOe,ECOf,ECOg,ECOh,ENOxa,ENOxb,ENOxc,ENOxd,ENOxe, &
		& ENOxf,ENOxg,ENOxh,EBCa,EBCb,EBCc,EBCd,EBCe,EBCf,EBCg, &
		& EBCh,EOCa,EOCb,EOCc,EOCd,EOCe,EOCf,EOCg,EOCh,ESO4a,ESO4b, &
		& ESO4c,ESO4d,ESO4e,ESO4f,ESO4g,ESO4h,EPMa,EPMb,EPMc, &
		& EPMd,EPMe,EPMf,EPMg,EPMh, &
		& ESO2a,ESO2b,ESO2c,ESO2d,ESO2e,ESO2f,ESO2g,ESO2h,ECO2a,& 
		& ECO2b,ECO2c,ECO2d,ECO2e,ECO2f,ECO2g,ECO2h)					 

		End program					 
		!子程序，求随机数的
		function my_random(lboundi,uboundi)
		Implicit none 
		real:: leng,t
		real:: lboundi,uboundi
		real::my_random
		leng=uboundi-lboundi
		call random_number(t)
		my_random=lboundi+leng*t
		End function my_random

		integer Function GetFileN( iFileUnit )
		Implicit None
		Logical , Parameter :: bIsSunRiseFromEast = .True.
		Integer , Intent( IN ) :: iFileUnit
		Character*(1) :: cDummy
		GetFileN = 0
		Rewind( iFileUnit )
		Do While ( bIsSunRiseFromEast )
		Read( iFileUnit , * , End = 999 , Err = 999 ) cDummy
		GetFileN = GetFileN + 1
		End Do
		999 Rewind( iFileUnit )
		Return
		End Function GetFileN 
