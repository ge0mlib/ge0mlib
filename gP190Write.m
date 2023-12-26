function gP190Write(DirNameNew,P190Head,Head,flDateSet,flagM)
%Write P190 Type_1 (Grid or Geographical coordinates) without Item 16 (RecordId='R': Receiver group records for 3-d offshore surveys).
%function gP190Write(DirNameNew,P190Head,Head,flDateSet,flagM), where
%DirNameNew- name of New-file/New-folder will be write (the files names will not change if new folder define);
%P190Head- structure with P190 header;
%Head- structure with P190 data.
%flagM- metric flag for Head.GpsLat, Head.GpsLon, Head.GpsE, Head.GpsN, Head.WaterDepth; symbols "M" (metric) or "N" (non metric) are used. Example: 'NNMMM' - Lat and Lon will saved in d.m.s.
%if flDateSet then P190Head.HData created for HType=='H0201'; value for set is "datestr(Head.GpsDay(1),'dd mmmm yyyy')".
%Used functions: gNavTime2Time,gNavAng2Ang
%Example: gP190Write('d:\P190\A1002_2DU_GUNz.190',P190Head,Head,0,'MMMMM'); gP190Write('d:\P190\',P190HeadZ,HeadZ,1,'NNMMM');
%============
%P190Head structure fields:
%P190Head.fNameN- name of files were read;
%P190Head.HType- Record Identifier 'H' + Header Record Type + Header Record Type Modifier (A1+I2+I2);
%P190Head.HDescript- Parameter Description (A27);
%P190Head.HData- Parameter Data (A48).
%============
%Head structure fields:
%Head.RecordId*- Char; Record identification (COL1; A1): 'S'=Centre of Source; 'G'=Receiver Group; 'Q'=Bin Centre; 'A'=Antenna Position; 'T'=Tailbuoy Position; 'C'=Common Mid Point; 'V'=Vessel Reference Point; 'E'=Echo Sounder; 'Z'=Other, defined in H0800.
%Head.LineName*- Char; Line name (left justified, including reshoot code) (COL2-13 A12);
%Head.Spare1*- Char; Spare (COL14-16 A3); if nonexist, then create values '   ';
%Head.VesselId*- Char; Vessel ID (COL17 A1);
%Head.SourceId*- Char; Source ID (COL18 A1);
%Head.OtherId*- Char; Tailbuoy / Other ID (COL19 A1);
%Head.PointNum- Float; Point number (right justified) (COL20-25 A6); if nonexist, then create values from 1 to N;
%Head.GpsLat- Float; Latitude in d.m.s. N/S (COL26-35 2(I2), F5.2, A1) or in grads N/S (COL26-35 F9.6, A1);
%Head.GpsLon- Float; Longitude in d.m.s. E/W (COL36-46 I3, I2, F5.2, A1) or in grads E/W (COL36-46 F10.6, A1);
%Head.GpsE- Float; Map grid Easting in metres (COL47-55 F9.1) or in non metric (COL47-55 I9);
%Head.GpsN- Float; Map grid Northing in metres (COL56-64 F9.1) or in non metric (COL56-64 I9);
%Head.WaterDepth*- Float; Water depth defined datum defined in H1700 (COL65-70 F6.1) or elevation in non metric (COL65-70 I6); if nonexist, then create values '   0.0';
%Head.GpsDay*- Float; Date (date number 1 corresponds to Jan-1-000; the year 0000 is merely a reference point); calculated using Julian Day of year (COL71-73 I3);
%Head.GpsTime- Float; Second in day; calculated using time h.m.s., GMT or as stated in H1000 (COL74-79 3I2);
%Head.Spare2*- Char; Spare (COL80 1X); if nonexist, then create values ' '.
%*- can be scalar, column will be created;
%"Applicable to 3-D Offshore Surveys" not used.
%============

if (size(DirNameNew,1)==1)&&(DirNameNew(end)=='\'),
    mkdir(DirNameNew);for nn=1:numel(P190Head), L=find(P190Head(nn).fNameN=='\');P190Head(nn).fNameN=[DirNameNew '\' P190Head(nn).fNameN(L(end)+1:end)];end;
elseif (size(DirNameNew,1)==1)&&(DirNameNew(end)~='\')&&(numel(Head)==1),
    P190Head.fNameN=DirNameNew;
end;

for nn=1:numel(P190Head),
    %======check P190Head and create P190HeadString======
    if size(P190Head(nn).HData,1)>48, error(['Error gP190Write: big P190Head.HData length' char(10) 'file:' P190Head(nn).fNameN]);end;
    if size(P190Head(nn).HData,1)<48, P190Head(nn).HData=[P190Head(nn).HData;repmat(' ',48-size(P190Head(nn).HData,1),size(P190Head(nn).HData,2))];end;
    L=P190Head(nn).HData==char(0);P190Head(nn).HData(L)=' ';%change char(0) to space
    if size(P190Head(nn).HDescript,1)>27, error(['Error gP190Write: big P190Head.HDescript length' char(10) 'file:' P190Head(nn).fNameN]);end;
    if size(P190Head(nn).HDescript,1)<27, P190Head(nn).HDescript=[P190Head(nn).HDescript;repmat(' ',27-size(P190Head(nn).HDescript,1),size(P190Head(nn).HDescript,2))];end;
    L=P190Head(nn).HDescript==char(0);P190Head(nn).HDescript(L)=' ';%change char(0) to space
    if size(P190Head(nn).HType,1)>5, error(['Error gP190Write: big P190Head.HType length' char(10) 'file:' P190Head(nn).fNameN]);end;
    if size(P190Head(nn).HType,1)<5, P190Head(nn).HType=[P190Head(nn).HType;repmat(' ',5-size(P190Head(nn).HType,1),size(P190Head(nn).HType,2))];end;
    L=P190Head(nn).HType==char(0);P190Head(nn).HType(L)=' ';%change char(0) to space
    if flDateSet,
        L=all(P190Head(nn).HType==repmat(('H0201')',1,size(P190Head(nn).HType,2)));
        if any(L),tmp=datestr(Head(nn).GpsDay(1),'dd mmmm yyyy')';P190Head(nn).HData(:,L)=[tmp;repmat(' ',48-size(tmp,1),1)];end;
    end;
    P190HeadString=[P190Head(nn).HType;P190Head(nn).HDescript;P190Head(nn).HData;repmat(char([13;10]),1,size(P190Head(nn).HType,2))];
    %======check Head======
    %===create nonexist fields with default values
    if ~isfield(Head(nn),'Spare1'), Head(nn).Spare1=('   ')';end;
    if ~isfield(Head(nn),'WaterDepth'), Head(nn).WaterDepth=0;end;
    if ~isfield(Head(nn),'Spare2'), Head(nn).Spare2=(' ');end;
    if ~isfield(Head(nn),'PointNum'), Head(nn).PointNum=(1:size(Head.GpsTime,2));end;
    if any(Head(nn).PointNum<0),warning(['gP190Write: PointNum <0 was found, abs(PointNum) was applyed;' char(10) 'file:' P190Head(nn).fNameN]);Head(nn).PointNum=abs(Head(nn).PointNum);end;
    if any(Head(nn).PointNum>999999),warning(['gP190Write: PointNum more than 999999 was found, mod(PointNum,999999) was applyed;' char(10) 'file:' P190Head(nn).fNameN]);Head(nn).PointNum=mod(Head(nn).PointNum,999999);end;
    %===create vectors for 'scalar' values
    if size(Head(nn).RecordId,2)==1, Head(nn).RecordId=repmat(Head(nn).RecordId,1,size(Head(nn).GpsTime,2));end;
    if size(Head(nn).LineName,2)==1, Head(nn).LineName=repmat(Head(nn).LineName,1,size(Head(nn).GpsTime,2));end;
    if size(Head(nn).Spare1,2)==1, Head(nn).Spare1=repmat(Head(nn).Spare1,1,size(Head(nn).GpsTime,2));end;
    if size(Head(nn).VesselId,2)==1, Head(nn).VesselId=repmat(Head(nn).VesselId,1,size(Head(nn).GpsTime,2));end;
    if size(Head(nn).SourceId,2)==1, Head(nn).SourceId=repmat(Head(nn).SourceId,1,size(Head(nn).GpsTime,2));end;
    if size(Head(nn).OtherId,2)==1, Head(nn).OtherId=repmat(Head(nn).OtherId,1,size(Head(nn).GpsTime,2));end;
    if size(Head(nn).WaterDepth,2)==1, Head(nn).WaterDepth=repmat(Head(nn).WaterDepth,1,size(Head(nn).GpsTime,2));end;
    if size(Head(nn).GpsDay,2)==1, Head(nn).GpsDay=repmat(Head(nn).GpsDay,1,size(Head(nn).GpsTime,2));end;
    if size(Head(nn).Spare2,2)==1, Head(nn).Spare2=repmat(Head(nn).Spare2,1,size(Head(nn).GpsTime,2));end;
    %===control fields values size
    if size(Head(nn).RecordId,1)~=1, error(['Error gP190Write: Head.RecordId length must be 1' char(10) 'file:' P190Head(nn).fNameN]);end;
    if size(Head(nn).LineName,1)>12, warning(['gP190Write: Head.LineName length must be 12; the right part was deleted' char(10) 'file:' P190Head(nn).fNameN]);Head(nn).LineName=Head(nn).LineName(1:12,:);end;
    if size(Head(nn).LineName,1)<12, Head(nn).LineName=[Head(nn).LineName;repmat(' ',12-size(Head(nn).LineName,1),size(Head(nn).LineName,2))];end;
    if size(Head(nn).Spare1,1)>3, error(['Error gP190Write: Head.Spare1 length must be 3' char(10) 'file:' P190Head(nn).fNameN]);end;
    if size(Head(nn).Spare1,1)<3, Head(nn).Spare1=[Head(nn).Spare1;repmat(' ',3-size(Head(nn).Spare1,1),size(Head(nn).Spare1,2))];end;
    if size(Head(nn).VesselId,1)~=1, error(['Error gP190Write: Head.VesselId length must be 1' char(10) 'file:' P190Head(nn).fNameN]);end;
    if size(Head(nn).SourceId,1)~=1, error(['Error gP190Write: Head.SourceId, length must be 1' char(10) 'file:' P190Head(nn).fNameN]);end;
    if size(Head(nn).OtherId,1)~=1, error(['Error gP190Write: Head.OtherId length must be 1' char(10) 'file:' P190Head(nn).fNameN]);end;
    if size(Head(nn).Spare2,1)~=1, error(['Error gP190Write: Head.Spare2 length must be 1' char(10) 'file:' P190Head(nn).fNameN]);end;
    %===formed HeadString
    strF='%c%s%s%c%c%c%6d';
    GpsLatS=repmat('N',1,size(Head(nn).GpsTime,2));GpsLatS(Head(nn).GpsLat<0)='S';Head(nn).GpsLat=abs(Head(nn).GpsLat);
    if flagM(1)=='N', Head(nn).GpsLat=gNavAng2Ang('D2DMS',Head(nn).GpsLat); strF=[strF '%9.2f%c']; else strF=[strF '%9.6f%c'];end;
    GpsLonS=repmat('E',1,size(Head(nn).GpsTime,2));GpsLonS(Head(nn).GpsLon<0)='W';Head(nn).GpsLon=abs(Head(nn).GpsLon);
    if flagM(2)=='N', Head(nn).GpsLon=gNavAng2Ang('D2DMS',Head(nn).GpsLon); strF=[strF '%10.2f%c']; else strF=[strF '%10.6f%c'];end;
    if flagM(3)=='N', strF=[strF '%9d']; else strF=[strF '%9.1f'];end;%Head.GpsE
    if flagM(4)=='N', strF=[strF '%9d']; else strF=[strF '%9.1f'];end;%Head.GpsN
    if flagM(5)=='N', strF=[strF '%6d']; else strF=[strF '%6.1f'];end;%Head.WaterDepth
    strF=[strF '%3d%06d%c\r\n'];
    [~,JulDay]=gNavTime2Time('Dx2YDy',Head(nn).GpsDay);
    TimeHHMMSS=round(gNavTime2Time('Sd2HMS',Head(nn).GpsTime));
    %======write to file======
    [fId,mes]=fopen(P190Head(nn).fNameN,'w');if ~isempty(mes),error(mes);end;
    fprintf(fId,'%s',P190HeadString);
    for n=1:size(Head(nn).GpsTime,2),
        fprintf(fId,strF,... %for metric >> '%c%s%s%c%c%c%6d%9.6f%c%10.6f%c%9.1f%9.1f%6.1f%3d%06d%c\r\n'
            Head(nn).RecordId(n),Head(nn).LineName(:,n),Head(nn).Spare1(:,n),Head(nn).VesselId(n),Head(nn).SourceId(n),Head(nn).OtherId(n),Head(nn).PointNum(n),...
            Head(nn).GpsLat(n),GpsLatS(n),Head(nn).GpsLon(n),GpsLonS(n),Head(nn).GpsE(n),Head(nn).GpsN(n),Head(nn).WaterDepth(n),JulDay(n),TimeHHMMSS(n),Head(nn).Spare2(n));
    end;
    fclose(fId);
    if ~mod(nn,50), disp(['File num: ',num2str(nn), '; File name:' P190Head(nn).fNameN]);end;%disp file number
end;
        
%mail@ge0mlib.com 02/11/2019