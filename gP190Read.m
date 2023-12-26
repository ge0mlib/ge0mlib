function [P190Head,Head]=gP190Read(fName,PYear)
%Read P190 Type_1 (Grid or Geographical coordinates) without Item 16 (RecordId='R': Receiver group records for 3-d offshore surveys).
%function [P190Head,Head]=gP190Read(fName,PYear), where
%fName- name of file/folder (with files) will be read;
%PYear- year for P190 survey data;
%P190Head- structure with P190 header;
%Head- structure with P190 data.
%Used functions: gNavTime2Time,gNavAng2Ang
%Example: [P190Head,Head]=gP190Read('d:\P190\A1002_2DU_GUN.190',2017); [P190HeadZ,HeadZ]=gP190Read('d:\P190\',2017);
%============
%P190Head structure fields:
%P190Head.fNameN- name of files were read;
%P190Head.HType- Record Identifier 'H' + Header Record Type + Header Record Type Modifier (A1+I2+I2);
%P190Head.HDescript- Parameter Description (A27);
%P190Head.HData- Parameter Data (A48).
%============
%Head structure fields:
%Head.RecordId- Char; Record identification (COL1; A1): 'S'=Centre of Source; 'G'=Receiver Group; 'Q'=Bin Centre; 'A'=Antenna Position; 'T'=Tailbuoy Position; 'C'=Common Mid Point; 'V'=Vessel Reference Point; 'E'=Echo Sounder; 'Z'=Other, defined in H0800.
%Head.LineName- Char; Line name (left justified, including reshoot code) (COL2-13 A12);
%Head.Spare1- Char; Spare (COL14-16 A3);
%Head.VesselId- Char; Vessel ID (COL17 A1);
%Head.SourceId- Char; Source ID (COL18 A1);
%Head.OtherId- Char; Tailbuoy / Other ID (COL19 A1);
%Head.PointNum- Float; Point number (right justified) (COL20-25 A6);
%Head.GpsLat- Float; Latitude in d.m.s. N/S (COL26-35 2(I2), F5.2, A1) or in grads N/S (COL26-35 F9.6, A1);
%Head.GpsLon- Float; Longitude in d.m.s. E/W (COL36-46 I3, I2, F5.2, A1) or in grads E/W (COL36-46 F10.6, A1);
%Head.GpsE- Float; Map grid Easting in metres (COL47-55 F9.1) or in non metric (COL47-55 I9);
%Head.GpsN- Float; Map grid Northing in metres (COL56-64 F9.1) or in non metric (COL56-64 I9);
%Head.WaterDepth- Float; Water depth defined datum defined in H1700 (COL65-70 F6.1) or elevation in non metric (COL65-70 I6);
%Head.GpsDay- Float; Date (date number 1 corresponds to Jan-1-000; the year 0000 is merely a reference point); calculated using Julian Day of year (COL71-73 I3);
%Head.GpsTime- Float; Second in day; calculated using time h.m.s., GMT or as stated in H1000 (COL74-79 3I2);
%Head.Spare2- Char; Spare (COL80 1X);
%"Applicable to 3-D Offshore Surveys" not used.
%============

if (size(fName,1)==1)&&(fName(end)=='\'), dz=dir(fName);dz([dz.isdir])=[];fName=[repmat(fName,length(dz),1) char(dz.name)];end;
fName=sortrows(fName);

P190Head(1:size(fName,1))=struct('fNameN','','HType','','HDescript','','HData','');
Head(1:size(fName,1))=struct('RecordId','','LineName','','Spare1','','VesselId','','SourceId','','OtherId','','PointNum',[],'GpsLat',[],'GpsLon',[],'GpsE',[],'GpsN',[],'WaterDepth',[],'GpsDay',[],'GpsTime',[],'Spare2','');
for nn=1:size(fName,1),
    fNameN=deblank(fName(nn,:));
    [fId,mes]=fopen(fNameN,'r');if ~isempty(mes),error(mes);end;
    S=fread(fId,[82 inf],'*char');fclose(fId);clear fId;
    if any(S(81,:)~=13)||any(S(82,:)~=10), warning(['gP190Read: unexpected EOL code (not CR/LF) for file;' char(10) ' file:' fNameN]);end;
    L=S(1,:)=='H';P190Head(nn)=struct('fNameN',fNameN,'HType',S(1:5,L),'HDescript',S(6:32,L),'HData',S(33:80,L)); %read header
    L=~L;
    GpsDay=gNavTime2Time('YDy2Dx',PYear,str2num(S(71:73,L)')');%used JulianDay
    GpsTime=gNavTime2Time('HMS2Sd',str2num(S(74:79,L)')');%used TimeHHMMSS
    Head(nn)=struct('RecordId',S(1,L),'LineName',S(2:13,L),'Spare1',S(14:16,L),'VesselId',S(17,L),'SourceId',S(18,L),'OtherId',S(19,L),...
        'PointNum',str2num(S(20:25,L)')','GpsLat',str2num(S(26:34,L)')','GpsLon',str2num(S(36:45,L)')','GpsE',str2num(S(47:55,L)')','GpsN',str2num(S(56:64,L)')',...
        'WaterDepth',str2num(S(65:70,L)')','GpsDay',GpsDay,'GpsTime',GpsTime,'Spare2',S(80,L));
    if all(S(32,L)=='.')&&all(S(43,L)=='.'),
        Head(nn).GpsLat=gNavAng2Ang('DMS2D',Head(nn).GpsLat);Head(nn).GpsLon=gNavAng2Ang('DMS2D',Head(nn).GpsLon);
    elseif ~(all(S(28,L)=='.')&&all(S(39,L)=='.')),
        error(['Error gP190Read: unexpected Latitude(must be I3I2F5.2 or F10.6)/Londitude(must be I2I2F5.2 or F9.6) format;' char(10) 'file:' fNameN]);
    end;
    if ~all(any(repmat(Head(nn).RecordId,9,1)==repmat(('SGQATCVEZ')',1,size(S(1,L),2)))), warning(['Error gP190Read: unexpected RecordId (must be S,G,Q,A,T,C,V,E,Z);' char(10) 'file:' fNameN]);end;
    Head(nn).GpsLat(S(35,L)=='S')=-Head(nn).GpsLat(S(35,L)=='S');Head(nn).GpsLon(S(46,L)=='W')=-Head(nn).GpsLon(S(46,L)=='W');
    if ~mod(nn,1), disp(['File num: ',num2str(nn), '; File name:' P190Head(nn).fNameN]);end;%disp file number
end;

%mail@ge0mlib.com 02/11/2019