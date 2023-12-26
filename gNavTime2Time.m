function varargout=gNavTime2Time(key,varargin)
%Convert date/time format varargin{1} to date/time format varargout{1} accordance key; round to 1e-9 digits.
%function varargout=gNavTime2Time(key,varargin), where
%varargin- converted date/time;
%varargout- date/time conversion result;
%key- formats key: HMS2Sd, Sd2HMS, HMS32Sd, Sd2HMS3, YMD2Dx, DMY2Dx, Dx2YMD, YMD32Dx, Dx2YMD3, YDy2Dx, Dx2YDy, DxSd2DmS, DmS2DxSd, DxSdDm2DmS, DxHMS32DmT, DmT2DxHMS3.
%varargin/varargout: HMS is HHMMSS.SSS; HMS3 is HH,MM,SS.SSSSSS; YMD is YYYYMMDD; YMD3 is YYYY,MM,DD.DDDD;
%Sd is second per day; S is second; Y is year; Ut is UnixTime (since 1/1/1970);
%Dx is serial date number of 1 corresponds to Jan-1-0000; Dy is Julian day; Dm is "point of origin" for Dx; 
%Example: Z=gNavTime2Time('YMD2Dx',20010210);[y,m,d]=gNavTime2Time('Dx2YMD3',Z);

switch key,
    case 'Sd2HMS',
        H=fix(varargin{1}./3600);M=fix((varargin{1}-H*3600)/60);S=varargin{1}-H*3600-M*60;varargout{1}=H*10000+M.*100+S; %SS.SSSS->HHMMSS.SSS
    case 'HMS2Sd',
        varargout{1}=fix(varargin{1}./10000).*3600+fix(mod(varargin{1},10000)./100).*60+mod(varargin{1},100); %HHMMSS.SSS->SS.SSSS
    case 'Sd2HMS3',
        varargout{1}=fix(varargin{1}./3600);varargout{2}=fix((varargin{1}-varargout{1}*3600)/60);varargout{3}=varargin{1}-varargout{1}*3600-varargout{2}*60; %SS.SSSS->HH,MM,SS.SSSSSS   ////varargout{2}=fix(mod(varargin{1}./3600,1).*60);%varargout{3}=mod(varargin{1}./60,1).*60;
    case 'Sd2HMS3z',
        varargout{1}(1,:)=fix(varargin{1}./3600);varargout{1}(2,:)=fix((varargin{1}-varargout{1}(1,:)*3600)/60);varargout{1}(3,:)=varargin{1}-varargout{1}(1,:)*3600-varargout{1}(2,:)*60; %SS.SSSS->HH,MM,SS.SSSSSS
    case 'HMS32Sd', 
        varargout{1}=varargin{1}.*3600+varargin{2}.*60+varargin{3}; %HH,MM,SS.SSSSSS->SS.SSSS
    case 'HMS3z2Sd', 
        varargout{1}=varargin{1}(1,:).*3600+varargin{1}(2,:).*60+varargin{1}(3,:); %HH,MM,SS.SSSSSS->SS.SSSS
    case 'DxSd2DmS'
        L=~isnan(varargin{1});varargout{1}=varargin{1}(L(1));varargout{2}=(varargin{1}-varargout{1}).*86400+varargin{2}; %D,Second-in-Day->DayZero,Second
    case 'DmS2DxSd',
        d=fix(varargin{2}./86400);varargout{1}=varargin{1}+d;varargout{2}=varargin{2}-d*86400; %DayZero,Second->D,Second-in-Day
    case 'DxSdDm2DmS',
        varargout{1}=varargin{3};varargout{2}=(varargin{1}-varargout{1}).*86400+varargin{2}; %D,Second-in-Day,DayZero->DayZero,Second
    case 'Dx2YMD', [Y,M,D]=datevec(varargin{1});varargout{1}=Y.*10000+M.*100+D+(varargin{1}-datenum(Y,M,D)); %D.DDDD->YYYYMMDD.DDD
    case 'YMD2Dx', varargout{1}=datenum(fix(varargin{1}./10000),fix(mod(varargin{1},10000)./100),mod(varargin{1},100)); %YYYYMMDD.DDD->D.DDDD
    case 'DMY2Dx', varargout{1}=datenum(mod(varargin{1},10000),fix(mod(varargin{1},1000000)./10000),fix(varargin{1}./1000000)); %DDMMYYYY->D
    case 'Dx2YMD3', [varargout{1},varargout{2},varargout{3}]=datevec(varargin{1});varargout{3}=varargout{3}+varargin{1}-datenum(varargout{1},varargout{2},varargout{3}); %D.DDDD->YYYY,MM,DD.DDDD
    case 'Dx2YMD3z', [varargout{1}(1,:),varargout{1}(2,:),varargout{1}(3,:)]=datevec(varargin{1});varargout{1}(3,:)=varargout{1}(3,:)+varargin{1}-datenum(varargout{1}(1,:),varargout{1}(2,:),varargout{1}(3,:)); %D.DDDD->YYYY,MM,DD.DDDD
    case 'YMD32Dx', varargout{1}=datenum(varargin{1},varargin{2},varargin{3}); %YYYY,MM,DD.DDDD->D.DDDD
    case 'YMD3z2Dx',varargout{1}=datenum(varargin{1}(1,:),varargin{1}(2,:),varargin{1}(3,:)); %YYYY,MM,DD.DDDD->D.DDDD
    case 'Dx2YDy', [varargout{1},~,~]=datevec(varargin{1});varargout{2}=varargin{1}-datenum(varargout{1},0,0); %D->Y,D_Julian
    case 'YDy2Dx', if all(size(varargin{1})==1),Y=repmat(varargin{1},size(varargin{2})); else Y=varargin{1};end;
        varargout{1}=datenum(Y,0,varargin{2}); %Y,D_Julian->D
    case 'DxHMS32DmT', L=~isnan(varargin{1});varargout{1}=varargin{1}(L(1));varargout{2}=(varargin{1}-varargout{1}).*86400+varargin{2}.*3600+varargin{3}.*60+varargin{4}; %D,HH,MM,SS->DayZero,Second
    case 'DmT2DxHMS3', d=floor(varargin{2}./86400);varargout{1}=varargin{1}+d;t=varargin{2}-d*86400;
        varargout{2}=fix(t./3600);varargout{3}=fix((t-varargout{2}*3600)/60);varargout{4}=t-varargout{2}*3600-varargout{3}*60;%DayZero,Second->D,HH,MM,SS
    case 'Ut2DxSd', varargout{1}=datenum(1970,1,1)+fix(varargin{1}./24./3600);varargout{2}=mod(varargin{1},24.*3600); %UnixTime->Dx,Sd
    case 'DxSd2Ut', varargout{1}=(varargin{1}-datenum(1970,1,1)).*24.*3600+varargin{2}; %Dx,Sd->UnixTime
    otherwise, error('Error gNavTime2Time: invalid key.');
end;

%mail@ge0mlib.com 16/05/2022