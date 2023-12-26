function [Us,QMask]=gFieldsDespike1D(t,U,QMask,QBit,QBitReset,Tr,IntP,SmoothP,f,varargin)
%Manual despike and smooth 1D data
%There are follow processing sequence: 1- data manual despike; 2- trend calculation; 3- data manual despike without trend; 4- despiked values linear interpolation; 5- interpolated data smooth
%function [Us,QMask]=gFieldsDespike1D(t,U,QMask,QBit,QBitReset,SmoothP,figN), where
%t- time-marks;
%U- 1D data;
%QMask- 32-bit uint mask;
%QBit- bit number from 1 to 32 used for "manual despike" marks;
%QBitReset- flag to reset QBit in QMask;
%Tr- trend calculation method // Tr{1}='const'; Tr{2}=constant // Tr{1}='poly'; Tr{2}=polynomial-trend's power // Tr{1}='smooth'; Tr{2}=points step; Tr{3}=smooth window size; Tr{4}=type of smooth; // Tr{1}=another, then external function call TrU=feval(Tr{1},t,U,Tr{2:end});
%IntP- paramiters for "interp1" function (interp method, extrap method);
%SmoothP- parameters for "smooth" function (window, method);
%f- figure number or pointer to draw raw 1D data, despiked data and smoothed data; if empty, than figure not drawn;
%varargin{1}- prefix for figures names;
%varargin{2}- flag for time fix;
%varargin{3}- axis label format.
%Function Example:
%[Mag.Depth,Mag.QMask]=gFieldsDespike1D(Mag.t,Mag.Depth,Mag.QMask,3,0,{'smooth',10,50,'loess'},{'linear','extrap'},{200,'loess'},100);

if (numel(varargin)<1),fPr='';else,fPr=varargin{1};end;
if (numel(varargin)<2),fl=1;elseif varargin{2},fl=1;else,fl=0;end;
if (numel(varargin)<3),lFr='%.3f';else,lFr=varargin{3};end;
if fl,xt=0:(numel(t)-1);plt=polyfit(xt,t,1);tt=polyval(plt,xt); a=figure('Name',[fPr 'TimeCheck_ax+b (a=' num2str(plt(1)) '; b=' num2str(plt(2)) ')'],'NumberTitle','off');plot(xt,t-tt,'.-b');hold on;gMapTickLabel(a,lFr,9);hold off;pause;close(a);end;
QBit=2.^(QBit-1);URaw=U;
if QBitReset, QMask=bitand(QMask,4294967295-QBit);end; U(bitand(QMask,QBit)~=0)=nan; %QBitReset used to reset QMask bit, after that set to Nan by QBit-mask for U
a=figure('Name',[fPr 'HighSpikes'],'NumberTitle','off');gMapTickLabel(a,lFr,9);[mask0,~]=gMapPickHandleNan2(t,U,a);close(a);U(mask0)=nan;
switch Tr{1}
    case 'const' %no trend
        TrU=repmat(Tr{2},size(t));
    case 'poly' %calc&remove polynomial-trend for U >> Tr{1}='poly'; Tr{2}=polynomial-trend's power;
        L=~isnan(U);plU=polyfit(t(L),U(L),Tr{2});TrU=polyval(plU,t);
    case 'smooth' %calc&remove smooth-trend for U >> Tr{1}='smooth'; Tr{2}=points step; Tr{3}=smooth window size; Tr{4}=type of smooth;
        L=find(~isnan(U));plU=smooth(t(L(1:Tr{2}:end)),U(L(1:Tr{2}:end)),Tr{3},Tr{4})';TrU=interp1(t(L(1:Tr{2}:end)),plU,t,'pchip','extrap');
    otherwise %external function
        TrU=feval(Tr{1},t,U,Tr{2:end});
end
a=figure('Name',[fPr 'LowSpikes_no_trend'],'NumberTitle','off');gMapTickLabel(a,lFr,9);[mask1,~]=gMapPickHandleNan2(t,U-TrU,a);close(a);U(mask1)=nan;
mask=mask0|mask1|(bitand(QMask,QBit)~=0);
QMask(mask)=bitor(QMask(mask),QBit);%Mark manual de-spiked U in QMask
U(mask)=interp1(t(~mask),U(~mask),t(mask),IntP{1},IntP{2});%inlerpolation&extrapolation for despiked values
if ~isempty(SmoothP),Us=smooth(t,U,SmoothP{1},SmoothP{2})';else,Us=U;end %Smooth
a=figure('Name',[fPr 'Smooth_no_trend'],'NumberTitle','off');plot(t(~mask),U(~mask),'.b');hold on;plot(t(mask),U(mask),'xr');plot(t,Us,'.g');gMapTickLabel(a,lFr,9);hold off;pause;close(a);
if ~isempty(f)
    if isnumeric(f),fp=figure(f);else,fp=f;end;
    gMapTickLabel(fp,lFr,9);hold on;plot(t,URaw,'.b');plot(t,TrU,'-b');plot(t(mask),URaw(mask),'xr');plot(t,Us,'.-g');hold off;
end
clearvars t U QBit QBitReset Tr SmoothP f URaw a mask0 mask L plU TrU mask1 fp

%mail@ge0mlib.com 27/03/2023