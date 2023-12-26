function [Es,Ns,QMask]=gFieldsDespike2D(t,E,N,QMask,QBit,QBitReset,Tr,IntP,SmoothP,f,varargin)
%Manual despike and smooth 2D data (like [E,N] coordinates).
%There are follow processing sequence: 1- data manual despike; 2- trend calculation; 3- data manual despike without trend; 4- despiked values linear interpolation; 5- interpolated data smooth
%function [Es,Ns,QMask]=gFieldsDespike2D(t,E,N,QMask,QBit,QBitReset,Tr,SmoothP,figN), where
%t- time-marks;
%E,N- 2D data;
%QMask- 32-bit uint mask;
%QBit- bit number from 1 to 32 used for "manual despike" marks;
%QBitReset- flag to reset QBit in QMask;
%Tr- trend calculation method // Tr{1}='const'; Tr{2}=constant // Tr{1}='poly'; Tr{2}=polynomial-trend's power // Tr{1}='smooth'; Tr{2}=points step; Tr{3}=smooth window size; Tr{4}=type of smooth; // Tr{1}=another, then external function call [TrE,TrN]=feval(Tr{1},t,E,N,Tr{2:end});
%IntP- paramiters for "interp1" function (interp method, extrap method);
%SmoothP- parameters for "smooth" function (window, method);
%f- figure number or pointer to draw raw 1D data, despiked data and smoothed data; if empty, than figure not drawn;
%varargin{1}- prefix for figures names;
%varargin{2}- flag for time fix;
%varargin{3}- axis label format.
%Function Example:
%[Mag.GpsE,Mag.GpsN,Mag.QMask]=gFieldsDespike2D(Mag.t,Mag.GpsE,Mag.GpsN,Mag.QMask,3,0,{'smooth',10,50,'loess'},{'linear','extrap'},{200,'loess'},100);

if (numel(varargin)<1),fPr='';else,fPr=varargin{1};end;
if (numel(varargin)<2),fl=1;elseif varargin{2},fl=1;else,fl=0;end;
if (numel(varargin)<3),lFr='%.3f';else,lFr=varargin{3};end;
if fl,xt=0:(numel(t)-1);plt=polyfit(xt,t,1);tt=polyval(plt,xt); a=figure('Name',[fPr 'TimeCheck_ax+b (a=' num2str(plt(1)) '; b=' num2str(plt(2)) ')'],'NumberTitle','off');plot(xt,t-tt,'.-b');hold on;gMapTickLabel(a,lFr,9);hold off;pause;close(a);end;
QBit=2.^(QBit-1);ERaw=E;NRaw=N;
if QBitReset, QMask=bitand(QMask,4294967295-QBit);end; E(bitand(QMask,QBit)~=0)=nan; N(bitand(QMask,QBit)~=0)=nan; %QBitReset used to reset QMask bit, after that set to Nan by QBit-mask for [E,N]
a=figure('Name',[fPr 'HighSpikes'],'NumberTitle','off');gMapTickLabel(a,lFr,9);[mask0,~]=gMapPickHandleNan2(E,N,a);close(a);E(mask0)=nan;N(mask0)=nan;
switch Tr{1}
    case 'const' %no trend
        TrE=repmat(Tr{2},size(t));TrN=repmat(Tr{2},size(t));
    case 'poly' %calc&remove polynomial-trend for U >> Tr{1}='poly'; Tr{2}=polynomial-trend's power;
        L=~isnan(E);plE=polyfit(t(L),E(L),Tr{2});TrE=polyval(plE,t);
        L=~isnan(N);plN=polyfit(t(L),N(L),Tr{2});TrN=polyval(plN,t);
    case 'smooth' %calc&remove smooth-trend for U >> Tr{1}='smooth'; Tr{2}=points step; Tr{3}=smooth window size; Tr{4}=type of smooth;
        L=find(~isnan(E));plE=smooth(t(L(1:Tr{2}:end)),E(L(1:Tr{2}:end)),Tr{3},Tr{4})';TrE=interp1(t(L(1:Tr{2}:end)),plE,t,'pchip','extrap');
        L=find(~isnan(N));plN=smooth(t(L(1:Tr{2}:end)),N(L(1:Tr{2}:end)),Tr{3},Tr{4})';TrN=interp1(t(L(1:Tr{2}:end)),plN,t,'pchip','extrap');
    otherwise %external function
        [TrE,TrN]=feval(Tr{1},t,E,N,Tr{2:end});
end
TrA=atan2(diff(TrE),diff(TrN));TrA(end+1)=TrA(end); %calculate line direction for point (0 is to N, clockwise is +);
TrDL=sin(-TrA).*(N-TrN)+cos(-TrA).*(E-TrE);TrDC=cos(-TrA).*(N-TrN)-sin(-TrA).*(E-TrE); %E'=sin(a)*N+cos(a)*E -- rot along trend // N'=cos(a)*N-sin(a)*E -- rot across trend
a=figure('Name',[fPr 'LowSpikes_along_trend'],'NumberTitle','off');gMapTickLabel(a,lFr,9);[mask1,~]=gMapPickHandleNan2(t,TrDL,a);close(a);TrDC(mask1)=nan;
a=figure('Name',[fPr 'LowSpikes_across_trend'],'NumberTitle','off');gMapTickLabel(a,lFr,9);[mask2,~]=gMapPickHandleNan2(t,TrDC,a);close(a);
mask=mask0|mask1|mask2|(bitand(QMask,QBit)~=0);
QMask(mask)=bitor(QMask(mask),QBit);%Mark manual de-spiked [E,N] in QMask
E(mask)=interp1(t(~mask),E(~mask),t(mask),IntP{1},IntP{2});N(mask)=interp1(t(~mask),N(~mask),t(mask),IntP{1},IntP{2});%inlerpolation&extrapolation for despiked values
if ~isempty(SmoothP),Es=smooth(t,E,SmoothP{1},SmoothP{2})';Ns=smooth(t,N,SmoothP{1},SmoothP{2})';else,Es=E;Ns=N;end %Smooth
TrDLr=sin(-TrA).*(NRaw-TrN)+cos(-TrA).*(ERaw-TrE);TrLs=sin(-TrA).*(Ns-TrN)+cos(-TrA).*(Es-TrE);
a=figure('Name',[fPr 'Smooth_along_trend'],'NumberTitle','off');plot(t(~mask),TrDL(~mask),'.b');hold on;plot(t(mask),TrDLr(mask),'xr');plot(t,TrLs,'.g');gMapTickLabel(a,lFr,9);hold off;pause;close(a);
TrDCr=cos(-TrA).*(NRaw-TrN)-sin(-TrA).*(ERaw-TrE);TrCs=cos(-TrA).*(Ns-TrN)-sin(-TrA).*(Es-TrE);
a=figure('Name',[fPr 'Smooth_across_trend'],'NumberTitle','off');plot(t(~mask),TrDC(~mask),'.b');hold on;plot(t(mask),TrDCr(mask),'xr');plot(t,TrCs,'.g');gMapTickLabel(a,lFr,9);hold off;pause;close(a);
if ~isempty(f)
    if isnumeric(f),fp=figure(f);else,fp=f;end;
    gMapTickLabel(fp,lFr,9);hold on;plot(ERaw,NRaw,'.b');plot(TrE,TrN,'-b');plot(ERaw(mask),NRaw(mask),'xr');plot(Es,Ns,'.-g');axis equal;hold off;
end
clearvars t E N QBit QBitReset Tr SmoothP f ERaw NRaw a mask L plE plN TrE TrN TrA TrL TrC mask1 mask2 TrLr TrLs TrCr TrCs fp

%mail@ge0mlib.com 27/03/2023