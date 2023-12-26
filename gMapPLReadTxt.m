function PL=gMapPLReadTxt(fName,keyRead,KeyLineDraw)
%Read data from txt-file to Track-polyline structure (2D-on-plane polyline).
%function PL=gMapPLReadTxt(fName,keyRead,KeyLineDraw), where
%fName- file name for reading;
%keyRead- key for reading: 1) LinePlan format; 2) PipeLineTrack format; 3) LinePlanKP file format; 4) Track in DTEN format;
%if keyRead(1)==2, than keyRead(2..5) is columns numbers for [E N KP Z PipeD], set NaN if data not exist for GpsKP or GpsZ
%if keyRead(1)==4, than keyRead(2..12) is [YYYY MM DD HH MM SS.SSS E N H KP Z], set NaN if data not exist for GpsH or GpsKP or GpsZ
%keyLineDraw- string key for line drawing: '-r','xb', etc;
%PL- output structure: PL(n).PLName, PL(n).Type, PL(n).KeyLineDraw, PL(n).GpsE, PL(n).GpsN;
%Extended fields are: PL(n).GpsH, PL(n).GpsKP, PL(n).GpsDay, PL(n).GpsTime, PL(n).PipeD.
%Example:
%PL=gMapPLReadTxt('c:\temp\SSS\V3LinePlan.txt',1,'-c');gMapPLDraw(100,PL);axis equal;PL=gMapPLReadTxt('c:\temp\SSS\V3LinePlan.txt',[2 1 2 5 nan nan],'-c');
%==============1-LinePlan file format=====================
%There are rows included LineName and E/Lat, N/Lon coordinates:
%LineName1, E1, N1, ..., En, Nn
%.............
%LineNameN, E1, N1, ..., En, Nn
%the delimiters are: ',' '\t' ';'.
%===============2-PipeLineTrack file format=======================
%There are a number of columns included E, N, KP(?), Z(?); columns positions are defined in keyRead;
%E, N, KP, Z, PipeD
%.............
%En, Nn, KPn, Zn, PipeDn
%the delimiters are: ',' '\t' ';'.
%===============3-LinePlanKP file format=======================
%There are rows included E, N, KP:
%LineName1, E1, N1, KP1, ..., En, Nn, KPn
%.............
%LineNameN, E1, N1, KP1, ..., En, Nn, KPn
%the delimiters are: ',' '\t' ';'.
%===============4-Track in DTEN format=======================
%There are a number of columns included Date, Time, E, N, H(?), KP(?), Z(?), WaterDepth(?):
%YYYY1 MM1 DD1 hh1 mm1 ss.sss1 E1 N1 H1 KP1 Z1 WaterDepth
%.............
%YYYYn MMn DDn hhn mmn ss.sssn En Nn Hn KPn Zn WaterDepth
%==============Axis========================================
%^y/N
%|
%o--->x/E

if (size(fName,1)==1)&&(fName(end)=='\'), dz=dir(fName);dz([dz.isdir])=[];fName=[repmat(fName,length(dz),1) char(dz.name)];end;fName=sortrows(fName);
PL=struct('PLName','','Type','','KeyLineDraw','','GpsE',[],'GpsN',[]);
nnn=0;
for nn=1:size(fName,1),
    fNameN=deblank(fName(nn,:));%disp(fNameN);
    switch keyRead(1),
        case 1 %LinePlan // Line planing, draw-objects and draw-targets file format read
            [fId, mes]=fopen(fNameN,'r');if ~isempty(mes), error(mes);end;F=fread(fId,'*char');fclose(fId);
            F(end+1)=char(13);L=F==char(10);F(L)=char(13); %rename char(10) to char(13), add char(13) to end
            L=find(F==char(13));L2=~[diff(L)~=1;1];F(L(L2))=[]; %delete doubles char(13)
            pos=find(F==char(13));pos_old=1;
            for n=1:length(pos),%read each row
                st=F(pos_old:pos(n))';pos_old=pos(n)+1;
                L=find((st==char(9))|(st==';')|(st==','));
                tmp=str2num(st(L(1)+1:end));tmp=reshape(tmp,[2 floor(length(tmp)./2+0.01)]);
                nnn=nnn+1;
                PL(nnn).PLName=st(1:L(1)-1);PL(nnn).Type='LinePlan';PL(nnn).KeyLineDraw=KeyLineDraw;
                PL(nnn).GpsE=tmp(1,:);PL(nnn).GpsN=tmp(2,:);
            end;
        case 2 %PipeLineTrack // Pipe-line track file format read: keyRead(2)>>E, keyRead(3)>>N column, keyRead(4) is KP column No, keyRead(5)>>Z;
            disp(fNameN);Dat=dlmread(fNameN);
            nnn=nnn+1;
            L1=find(fNameN=='\');if isempty(L1),z1=0;else z1=L1(end);end;
            L2=find(fNameN=='.');if isempty(L2),z2=numel(fNameN)+1;else z2=L2(end);end;
            PL(nnn).PLName=fNameN(z1+1:z2-1);PL(nnn).Type='PipeLineTrack';PL(nnn).KeyLineDraw=KeyLineDraw;
            PL(nnn).GpsE=Dat(:,keyRead(2))';PL(nnn).GpsN=Dat(:,keyRead(3))';
            if (numel(keyRead)>3)&&(~isnan(keyRead(4))), PL(nnn).GpsKP=Dat(:,keyRead(4))';end;
            if (numel(keyRead)>4)&&(~isnan(keyRead(5))), PL(nnn).GpsZ=Dat(:,keyRead(5))';end;
            if (numel(keyRead)>5)&&(~isnan(keyRead(6))), PL(nnn).PipeD=Dat(:,keyRead(6))';end;
        case 3 %LinePlanKP // Line planing with KP-number file format read
            [fId, mes]=fopen(fNameN,'r');if ~isempty(mes), error(mes);end;F=fread(fId,'*char');fclose(fId);
            F(end+1)=char(13);L=F==char(10);F(L)=char(13); %rename char(10) to char(13), add char(13) to end
            L=find(F==char(13));L2=~[diff(L)~=1;1];F(L(L2))=[]; %delete doubles char(13)
            pos=find(F==char(13));pos_old=1;
            for n=1:length(pos),%read each row
                st=F(pos_old:pos(n))';pos_old=pos(n)+1;
                L=find((st==char(9))|(st==';')|(st==','));
                tmp=str2num(st(L(1)+1:end));tmp=reshape(tmp,[3 floor(length(tmp)./3+0.01)]);
                nnn=nnn+1;
                PL(nnn).PLName=st(1:L(1)-1);PL(nnn).Type='LinePlanKP';PL(nnn).KeyLineDraw=KeyLineDraw;
                PL(nnn).GpsE=tmp(1,:);PL(nnn).GpsN=tmp(2,:);PL(nnn).GpsKP=tmp(3,:);
            end;
        case 4 %Track // Track-plot in DTEN format: keyRead(2)>>YYYY, keyRead(3)>>MM, keyRead(4)>>DD, keyRead(5)>>HH, keyRead(6)>>MM, keyRead(7)>>SS.SSS, keyRead(8)>>E, keyRead(9)>>N, keyRead(10)>>H, keyRead(11)>>KP, keyRead(12)>>Z
            Dat=dlmread(fNameN);
            nnn=nnn+1;
            L1=find(fNameN=='\');if isempty(L1),z1=0;else z1=L1(end);end;
            L2=find(fNameN=='.');if isempty(L2),z2=numel(fNameN)+1;else z2=L2(end);end;
            PL(nnn).PLName=fNameN(z1+1:z2-1);PL(nnn).Type='Track';PL(nnn).KeyLineDraw=KeyLineDraw;
            PL(nnn).GpsDay=gNavTime2Time('YMD32Dx',Dat(:,keyRead(2),Dat(:,keyRead(3)),Dat(:,keyRead(4))))';PL(nnn).GpsTime=gNavTime2Time('HMS32Sd',Dat(:,keyRead(5)),Dat(:,keyRead(6)),Dat(:,keyRead(7)))';
            PL(nnn).GpsE=Dat(:,keyRead(8))';PL(nnn).GpsN=Dat(:,keyRead(9))';
            if ~isnan(keyRead(10)),PL(nnn).GpsH=Dat(:,keyRead(10))';end;if ~isnan(keyRead(11)),PL(nnn).GpsKP=Dat(:,keyRead(11))';end;
            if ~isnan(keyRead(12)),PL(nnn).GpsZ=Dat(:,keyRead(12))';end;if ~isnan(keyRead(13)),PL(nnn).WaterDepth=Dat(:,keyRead(13))';end;
        otherwise, error('Unexpected keyRead code');
    end;
end;

%mail@ge0mlib.com 18/10/2020