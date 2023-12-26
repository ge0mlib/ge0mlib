function [SgyHeadD,HeadD,DataD,HrzD]=gSgyHorizTime2Depth(SgyHead,Head,Data,VelMat,min_dd,Hrz,FieldX,FieldY)
%Convert Data-matrix from time to depth, using Velocity matrix; the horizons structure is converted too.
%function [SgyHeadD,HeadD,DataD,HrzD]=gSgyHorizTime2Depth(SgyHead,Head,Data,VelMat,Hrz,min_dd), where
%SgyHead,Head,Data- Sgy variables in time; if SgyHead is empty, than convert SBP-horizon only (no conversion to depth for seismic section);
%VelMat- Velocity Matrix same size with Data matrix filled using horizons (based on Velocities below horizons).
%Hrz(1..m)- SBP-horizons; can be empty (no conversion to depth for horizons); there are follow fields:
%  Hrz(n).PLName- horizon's name and identifier for mapping;
%  Hrz(n).KeyLineDraw- string key for line drawing: '-r','xb', etc;
%  Hrz(n).pX, Hrz(n).pY- base-points for picking (applied for compatibility with picking functions);
%  Hrz(n).PickL=[xL yL]- two-rows vector with trace number and horizon's depth in digits (for each Image pixel); if horizon is not exist, than yL(n1..n2)==nan;
%  Hrz(n).Vbelow- velocity below horizon in m/s;
%min_dd- size for depth-step, integer number in millimeters; if empty, than will used a minimal step for converted Data;
%SgyHeadD,HeadD,DataD- sgy structure converted to depth;
%HrzD- horizons converted to depth; includes additional fields:
%  HrzD(n).fName- horizon's source file name;
%  HrzD(n).Digit- scalar, one digit "length" for Data matrix;
%  HrzD(n).GpsE- horizon’s points X or Easting coordinates;
%  HrzD(n).GpsN- horizon’s points Y or Northing coordinates.
%Example: Hrz(1)=gSgyHorizCreate(1,size(Data),1500,[],'first','.-b');Hrz(2)=gSgyHorizCreate(Head.UnassignedInt1,size(Data),2000,[],'bottom','.-b');
%VelMat=gSgyHoriz2VelMatrix(Hrz,size(Data),1);[SgyHeadD,HeadD,DataD,HrzD]=gSgyHorizTime2Depth(SgyHead,Head,Data,VelMat,Hrz,[]);

if any(Head.dt~=Head.dt(1)), warning('dt is changed for traces.');end;
ddData=repmat(Head.dt.*1e-3,size(Data,1),1).*VelMat./2;
dData=cumsum(ddData,1);%ddData and dData in millimeters
if isempty(min_dd),min_dd=round(min(min(ddData)));end; %minimal depth-step in millimeters
%===convert Horizons
HrzD=Hrz;
for n=1:length(HrzD),
    HrzD(n).pY=round(dData(Hrz(n).pY)./min_dd);HrzD(n).PickL(2,:)=round(dData(Hrz(n).PickL(2,:))./min_dd);
    HrzD(n).Digit=min_dd;HrzD(n).fName=SgyHead.fName;HrzD(n).GpsE=Head.(FieldX);HrzD(n).GpsN=Head.(FieldY);
end;
%===convert Data-matrix to Depth
if ~isempty(SgyHead),
    no=1:size(dData,1);%digit number for dData
    tn=min_dd:min_dd:max(dData(end,:));%vertical scale for depth interpolation
    DataD=nan(numel(tn),size(Data,2));
    for n=1:size(Data,2),
        nn=round(interp1(dData(:,n),no,tn,'linear'));
        nn(isnan(nn))=[];DataD(1:numel(nn),n)=Data(nn,n);
    end;
    %===convert Sgy-fields
    SgyHeadD=SgyHead;SgyHeadD.dt=min_dd;SgyHeadD.dtOrig=min_dd;SgyHeadD.ns=numel(tn);SgyHeadD.nsOrig=numel(tn);
    HeadD=Head;HeadD.ns(:)=numel(tn);HeadD.dt(:)=min_dd;
    HeadD.UnassignedInt1=round(dData(Head.UnassignedInt1)./min_dd);%convert picked original sea depth
    HeadD.UnassignedInt2=round(dData(Head.UnassignedInt1)./min_dd);%convert processed sea depth
else SgyHeadD=[];HeadD=[];DataD=[];
end;

%mail@ge0mlib.com 15/02/2019