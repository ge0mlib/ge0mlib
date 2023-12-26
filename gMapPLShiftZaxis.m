function [PL,varargout]=gMapPLShiftZaxis(PL,dMax,NumIter,drFl,AcadFile)
%Minimized mean Z-axis difference for Track-polylines set in a cross points. The function shifted PLs, using PL(n).GpsZ=PL(n).GpsZ+difference. Each PL must have one cross-point minimum.
%function function [PL,varargout]=gMapPLShiftZaxis(PL,dMax,NumIter,drFl,AcadFile), where
%PL - input structure: PL(n).PLName; PL(n).GpsKP; PL(n).GpsE; PL(n).GpsN; PL(n).GpsZ; PL(n).Type; PL(n).KeyLineDraw;
%dMax - maximum mean Z-difference between crosses for each PL;
%NumIter - maximum number of iteration for PL's shifting;
%drFl - flag for draw figure with differences;
%AcadFile - file name for Autocad's script (no file will be created if empty);
%PL - output structure: PL(n).PLName; PL(n).GpsKP; PL(n).GpsE; PL(n).GpsN; PL(n).GpsZ; PL(n).Type; PL(n).KeyLineDraw;
%varargout{1} - dZshift - adds for each PL;
%varargout{2}=[dZpl dZstd dZnum dZmad dZrms] - statistical estimations:
%   dZpl - mean GpsZ-difference between crosses for each PL;
%   dZstd - standard deviation around dZpl;
%   dZnum - the number of cross-points;
%   dZmd - mean absolute for Z-differences (for all PL's crosses);
%   dZrm - root-mean-square for Z-differences;
%varargout{3} - dZnode - max differens value for all crosses;
%varargout{4} - Num - crosses-matrix;
%varargout{5} - Num2 - balanced crosses-matrix.
%Remark: the "nanmean" function for using without Statistical Toolbox was added as a local (see below).
%Example: [PL2,dZshift,dZpl,dZnode,Num,Num2]=gMapPLShiftZaxis(PL,0.01,500000,1,'c:\temp\zshift');

DistCross=3;
for n1=1:length(PL),PL(n1).Num=1:length(PL(n1).GpsKP);end; %Create field with PL-point-number
%=====Create table with PL-cross-nodes in Num=====
Len=length(PL);Num=nan(Len,Len,4);
for n1=1:Len, %disp([999 n1]);
    for n2=n1+1:Len, %disp(n2);
        [nk2,nK2,Dmin]=gMapGeomPoints2DMinDist([PL(n1).Num;PL(n1).GpsE;PL(n1).GpsN],[],[PL(n2).Num;PL(n2).GpsE;PL(n2).GpsN],[],1);%find min distance between points for "crossed" PL
        if Dmin<DistCross, %if min distance < DistCross then PL's are "crossed"
            %There are Layer(1)-point No for PL in rows; Layer(2)- GpsZ for PL in rows; Layer(3)-point No for PL in column; Layer(4)- GpsZ for PL in column;
            Num(n1,n2,:)=[nk2(1) PL(n1).GpsZ(nk2(1)) nK2(1) PL(n2).GpsZ(nK2(1))];Num(n2,n1,:)=[nK2(1) PL(n2).GpsZ(nK2(1)) nk2(1) PL(n1).GpsZ(nk2(1))];
        end;
    end;
end;
%=====Iteration PL-shifting===== >> minimized mean abs deviation
Num2=Num;n=0;mv=1;
while (n<NumIter)&&(mv>dMax),
    n=n+1;
    dZpl=nanmean(Num2(:,:,2)-Num2(:,:,4));
    [mv,mn]=max(abs(dZpl)); %dZpl - mean delta values for PL-in-column; mv - max_abs from mean delta values; mn - mv's PL number;
    Num2(:,mn,4)=Num2(:,mn,4)+dZpl(mn);Num2(mn,:,2)=Num2(mn,:,2)+dZpl(mn); %PL-in-column+delta;PL-in-row+delta;
end;
%=====Create output figure=====
dZshift=nanmean(Num2(:,:,4)-Num(:,:,4));%mean delta values for PL-in-column
for n1=1:Len, PL(n1).GpsZ=PL(n1).GpsZ+dZshift(n1);end;%add delta's to PL
varargout{1}=dZshift;
tmp1=Num2(:,:,2)-Num2(:,:,4);dZpl=nanmean(tmp1);L=~isnan(tmp1(:));tmp2=sqrt(sum(tmp1(L).^2)./numel(tmp1(L)));tmp3=sum(abs(tmp1(L)))./numel(tmp1(L));
varargout{2}=[dZpl std(tmp1(L)) sum(L)./2 tmp2 tmp3];Df=Num2(:,:,2)-Num2(:,:,4);varargout{3}=max(max(abs(Df(~isnan(Df)))));varargout{4}=Num;varargout{5}=Num2;
if drFl,
    figure(101);hold on;axis equal;
    for n1=1:Len,
        plot(PL(n1).GpsE,PL(n1).GpsN,'.');
        text(PL(n1).GpsE(1),PL(n1).GpsN(1),[PL(n1).PLName ':' num2str(dZshift(n1)) '/' num2str(dZpl(n1))],'FontSize',8,'Color',[0 0 0],'Interpreter','none','VerticalAlignment','baseline');
        for n2=n1+1:Len,
            if ~isnan(Num2(n1,n2,1)),
                plot(PL(n1).GpsE(Num2(n1,n2,1)),PL(n1).GpsN(Num2(n1,n2,1)),'o');
                text(PL(n1).GpsE(Num2(n1,n2,1)),PL(n1).GpsN(Num2(n1,n2,1)),['   ' num2str(abs(Num2(n1,n2,2)-Num2(n1,n2,4)))],'FontSize',8,'Color',[0 0 0],'Interpreter','none','VerticalAlignment','baseline');
            end;
        end;
    end;
end;
%=====Create output Acad=====
if ~isempty(AcadFile),
    fId=fopen(AcadFile,'w');DigitNum=2;PLName_Text_Size=12;PLName_Text_Angle=0;Circles_Radius=1;PLCross_Text_Size=1;PLCross_Text_Angle=0;
    gAcadZoom(fId,[0 0 0.0001],4);
    for n1=1:Len,
        gAcadPline(fId,PL(n1).GpsE,PL(n1).GpsN,[DigitNum DigitNum]);
        gAcadText(fId,PL(n1).GpsE(1),PL(n1).GpsN(1),PLName_Text_Size,PLName_Text_Angle,[PL(n1).PLName ':' num2str(dZshift(n1)) '/' num2str(dZpl(n1))],[DigitNum DigitNum]);
        for n2=n1+1:Len,
            if ~isnan(Num2(n1,n2,1)),
                gAcadCircle(fId,PL(n1).GpsE(Num2(n1,n2,1)),PL(n1).GpsN(Num2(n1,n2,1)),Circles_Radius,[DigitNum DigitNum 0]);
                gAcadText(fId,PL(n1).GpsE(Num2(n1,n2,1)),PL(n1).GpsN(Num2(n1,n2,1)),PLCross_Text_Size,PLCross_Text_Angle,num2str(abs(Num2(n1,n2,2)-Num2(n1,n2,4))),[DigitNum DigitNum]);
            end;
        end;
    end;
    fclose(fId);
end;
PL=rmfield(PL,'Num'); %Remove field with PL-point-number

%nanmean without Statistical Toolbox
%function Anm=nanmean(A), AL=isnan(A);A(AL)=0;Anm=sum(A)./sum(~AL);

%mail@ge0mlib.com 17/10/2020