function gP1902Cat(P190Head,Head,fName,fHeadStr,stp)
%Convert P190 structure to coordinates-catalog-file in txt.
%function gP1902Cat(P190Head,Head,fName,fHeadStr,stp), where
%P190Head- structure with P190 header;
%Head- structure with P190 data;
%fName- name of file for catalog-data write;
%fHeadStr- string will be write in txt-file before each P190;
%stp- step for survey points.
%Catalog rows values: 1)file name from P190Head.fNameN; 2)Head.PointNum; 3)Head.GpsDay; 4)Head.GpsTime; 5)Head.GpsLat; 6)Head.GpsLon; 7)Head.GpsE; 8)Head.GpsN; 9)Head.WaterDepth.
%Title for each file, was included to catalog, is: FileName,PointNum,Date,Time,Latitude,Longitude,Easting,Nosting,WaterDepth
%Catalog includes first and last points from survey line.
%Used functions: gNavTime2Time,gNavAng2Ang
%Example: [P190Head,Head]=gP190Read('d:\P190\',2017);gP1902Cat(P190Head,Head,'d:\P190.txt',10);
%============
%P190Head structure fields: P190Head.fNameN, P190Head.HType, P190Head.HDescript, P190Head.HData.
%Head structure fields: Head.RecordId, Head.LineName, Head.Spare1, Head.VesselId, Head.SourceId, Head.OtherId, Head.PointNum,Head.GpsLat, Head.GpsLon, Head.GpsE, Head.GpsN, Head.WaterDepth, Head.GpsDay, Head.GpsTime, Head.Spare2.
%"Applicable to 3-D Offshore Surveys" not used.

SHeader=[ fHeadStr char([13 10]) 'FileName' char(9) 'PointNum' char(9) 'Date' char(9) 'Time' char(9) 'Latitude' char(9) 'Longitude' char(9) 'Easting' char(9) 'Nosting' char(9) 'WaterDepth'];
[fId,mes]=fopen(fName,'w');if ~isempty(mes),error(mes);end;
for nn=1:numel(P190Head),
    num=1:stp:length(Head(nn).GpsDay);if num(end)~=length(Head(nn).GpsDay),num=[num length(Head(nn).GpsDay)];end;%forced add last point
    Len=numel(Head(nn).GpsDay(num));tt=repmat(char(9),1,Len);
    L1=find(P190Head(nn).fNameN=='\');L2=find(P190Head(nn).fNameN=='.');if isempty(L1), L1=0;end;if isempty(L2), L2=numel(P190Head(nn).fNameN)+1;end;
    Name=P190Head(nn).fNameN(L1(end)+1:L2(end)-1);
    [t1,t2,t3]=gNavTime2Time('Dx2YMD3',Head(nn).GpsDay(num));SDate=[num2str(t1','%04d')';repmat('/',1,Len);num2str(t2','%02d')';repmat('/',1,Len);num2str(t3','%02d')'];
    [t1,t2,t3]=gNavTime2Time('Sd2HMS3',Head(nn).GpsTime(num));STime=[num2str(t1','%02d')';repmat(':',1,Len);num2str(t2','%02d')';repmat(':',1,Len);num2str(t3','%05.2f')'];
    GpsLatS=repmat('N',1,Len);GpsLatS(Head(nn).GpsLat(num)<0)='S';
    [t1,t2,t3]=gNavAng2Ang('D2DMS3',abs(Head(nn).GpsLat(num)));SLat=[num2str(t1','%02d')';repmat(char(176),1,Len);num2str(t2','%02d')';repmat(char(39),1,Len);num2str(t3','%06.3f')';repmat(char(34),1,Len);GpsLatS];
    GpsLonS=repmat('E',1,Len);GpsLonS(Head(nn).GpsLon(num)<0)='W';
    [t1,t2,t3]=gNavAng2Ang('D2DMS3',abs(Head(nn).GpsLon(num)));SLon=[num2str(t1','%03d')';repmat(char(176),1,Len);num2str(t2','%02d')';repmat(char(39),1,Len);num2str(t3','%06.3f')';repmat(char(34),1,Len);GpsLonS];
    SNum=num2str(Head(nn).PointNum(num)','%d')';
    SE=num2str(Head(nn).GpsE(num)','%08.1f')';SN=num2str(Head(nn).GpsN(num)','%09.1f')';SD=num2str(Head(nn).WaterDepth(num)','%06.2f')';
    fprintf(fId,'%s\r\n',SHeader);fprintf(fId,'%s\r\n',[repmat(Name',1,Len);tt;SNum;tt;SDate;tt;STime;tt;SLat;tt;SLon;tt;SE;tt;SN;tt;SD;repmat(char([13;10]),1,Len)]);
end;
fclose(fId);

%mail@ge0mlib.com 07/11/2020