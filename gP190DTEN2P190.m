function [P190Head,PHead]=gP190DTEN2P190(MainHead,Head,NavP,NavOutGeog,NavOutProj,fP190Head,RecordId,Spare1,VesselId,SourceId,OtherId,Spare2)
%Create P190 structure (P190 Type_1, without Item 16) using DTEN fields from Dataset (sgy, xtf, etc).
%function [P190Head,PHead]=gP190DTEN2P190(MainHead,Head,NavP,NavOutGeog,NavOutProj,fP190Head,RecordId,Spare1,VesselId,SourceId,OtherId,Spare2), where
%MainHead- converted MainHead(1..n) structure (XtfHead, SgyHead, etc);
%Head- converted Head(1..n) structure;
%NavP- (see gNavCoord2Coord) navigation datum for Project, fields: EllipParam, ProjParam, ProjForvFunc, ProjRevFunc, TargCode;
%NavOutGeog- (see gNavCoord2Coord) navigation datum for Output Geographic, fields: EllipParam, ProjParam, ProjForvFunc, ProjRevFunc, EllipTransParam, EllipForvTransFunc, EllipRevTransFunc, TargCode;
%NavOutProj- (see gNavCoord2Coord) navigation datum for Output Projection, fields: EllipParam, ProjParam, ProjForvFunc, ProjRevFunc, EllipTransParam, EllipForvTransFunc, EllipRevTransFunc, TargCode;
%fP190Head- file name which containe P190Head (header for P190);
%RecordId- char or chars vector for Head.RecordId (P190 structure);
%Spare1- 3-chars or 3-chars vector for Head.Spare1 (P190 structure);
%VesselId- char or chars vector for Head.VesselId (P190 structure);
%SourceId- char or chars vector for Head.SourceId (P190 structure);
%OtherId- char or chars vector for Head.OtherId (P190 structure);
%Spare2- char or chars vector for Head.Spare2 (P190 structure);
%[P190Head,PHead]- P190 structure fields.
%Example:
%NavP=struct('EllipParam',[6378137 0.081819190842],'ProjParam',[0 142 0.9996 500000 0],'ProjForvFunc','gNavGeog2ProjUtm','ProjRevFunc','gNavProjUtm2Geog','TargCode',6);
%NavOutGeog=struct('EllipParam',[6378137 0.081819190842],'ProjParam',[0 142 0.9996 500000 0],'ProjForvFunc','gNavGeog2ProjUtm','ProjRevFunc','gNavProjUtm2Geog','TargCode',2);
%NavOutProj=struct('EllipParam',[6378137 0.081819190842],'ProjParam',[0 142 0.9996 500000 0],'ProjForvFunc','gNavGeog2ProjUtm','ProjRevFunc','gNavProjUtm2Geog','TargCode',1);
%[P190Head,PHead]=gP190DTEN2P190(XtfHead,Head,'HMessageNum',NavP,NavOutGeog,NavOutProj,'c:\temp\P190_Header.txt','S',('   ')','1','1',' ',' ');

[P190Head0,~]=gP190Read(fP190Head,2000);P190Head(1:numel(Head))=P190Head0;
PHead(1:numel(Head))=struct('RecordId',RecordId,'Spare1',Spare1,'VesselId',VesselId,'SourceId',SourceId,'OtherId',OtherId,'Spare2',Spare2);
for n=1:length(MainHead),
    PHead(n).PointNum=Head(n).GpsKP;
    if isfield(Head(n),'WaterDepth'),PHead(n).WaterDepth=Head(n).WaterDepth; else PHead(n).WaterDepth=zeros(size(Head(n).GpsKP));end;
    PHead(n).GpsDay=Head(n).GpsDay;PHead(n).GpsTime=Head(n).GpsTime;
    L1=find(MainHead(n).fName=='\');L2=find(MainHead(n).fName=='.');
    PHead(n).LineName=(MainHead(n).fName(L1(end)+1:L2(end)-1))';
    [PHead(n).GpsLat,PHead(n).GpsLon,~]=gNavCoord2Coord(Head(n).GpsE,Head(n).GpsN,Head(n).GpsH,NavOutGeog,NavP,[NavP.TargCode NavOutGeog.TargCode]);
    [PHead(n).GpsE,PHead(n).GpsN,~]=gNavCoord2Coord(Head(n).GpsE,Head(n).GpsN,Head(n).GpsH,NavOutProj,NavP,[NavP.TargCode NavOutProj.TargCode]);
    P190Head(n).fNameN=[MainHead(n).fName(1:L2(end)) '190'];
end;

%mail@ge0mlib.ru 08/11/2019