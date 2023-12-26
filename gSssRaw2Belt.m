function [Data,DataL,DataX]=gWfrSssRaw2Belt(Data1,Data2,SamplingInterval,Altitude,GpsE,GpsN,CompassHeading,WVel,fig_fl)
%Calculate SSS-belt using raw SSS data.
%function [Data,DataL,DataX,a]=gWfrSssRaw2Belt(Data1,Data2,SamplingInterval,Altitude,GpsE,GpsN,CompassHeading,WVel,fig_fl), where
%====Input====
%Data1- left channel;
%Data2- right channel;
%SamplingInterval- Sampling Interval for both channels (sec);
%Altitude- SSS altitude (m);
%GpsE- easting (m);
%GpsN- northing (m);
%CompassHeading- SSS heading (deg);
%WVel- water welocity (m/sec);
%fig_fl- figure handler.
%====Output====
%Data- SSS's "reflection points";
%DataL- DataE, easting for "reflection points"(m);
%DataX- DataN, northing for "reflection points"(m);
%a- figure handler.
%Example for Jsf:
%LL=1:1000;gWfrSssRaw2Belt(Data1(:,LL),Data2(:,LL),Head.SamplingInterval(LL).*1e-9,Head.Altitude(LL)./1000,[],[],[],1500,1);
%LL=1:1000;[Data,DataE,DataN,~]=gWfrSssRaw2Belt(Data1(:,LL),Data2(:,LL),Head.SamplingInterval(LL).*1e-9,Head.Altitude(LL)./1000,Head.GpsE(LL),Head.GpsN(LL),Head.CompassHeading(LL)./100,1500,1);

Data=[flipud(Data1);Data2]; clearvars Data1 Data2;
[DataY,DataX]=ndgrid(-(size(Data,1)/2):(size(Data,1)/2-1),1:size(Data,2));DataY=DataY+0.5;
DataL=sqrt((DataY.*SamplingInterval.*WVel./2).^2-Altitude.^2).*sign(DataY);DataL(imag(DataL)~=0)=1; clearvars DataY
if ~(isempty(GpsE)||isempty(GpsN)||isempty(CompassHeading)) %with Navigation
    PingHeading=(CompassHeading(DataX)+90.*sign(DataL))./180.*pi;
    DataR=abs(DataL).*exp(PingHeading.*1i)+GpsN(DataX)+GpsE(DataX).*1i;clearvars DataL PingHeading DataX
    DataL=imag(DataR);DataX=real(DataR);clearvars DataR %DataL==DataE; DataX==DataN;
end
if ~isempty(fig_fl)
    tmp=Data([1 end],:);Data([1 end],:)=nan;
    a=figure(fig_fl);for n=1:size(Data,2),patch(gca,DataL(:,n),DataX(:,n),log(Data(:,n)),'EdgeColor','flat','LineWidth',3);end;colormap(gca,1-colormap(gca,'gray'));set(gca,'color','none');gMapTickLabel(a,'%.2f',9);
    if ~(isempty(GpsE)||isempty(GpsN)||isempty(CompassHeading)),axis equal;end
    Data([1 end],:)=tmp;
end

%mail@ge0mlib.ru 09/02/2022