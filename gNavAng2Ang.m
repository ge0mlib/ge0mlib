function varargout=gNavAng2Ang(key,varargin)
%Convert angle format varargin{1} to angle format varargout{1} accordance key.
%function varargout=gNavAng2Ang(key,varargin), where
%varargin- converted angle;
%varargout- conversion result;
%key- formats key: DMS2D, D2DMS, DMS32D, D2DMS3, DM2D, D2DM, D2R, R2D.
%DMS is DDDMMSS.SSS; DMS3 is D,M,S; DM is DDDMM.MMM; D is DD.DDDDD; R is RR.RRRR (Degree/Minute/Second/Radian).
%Example: Ang2=gNavAng2Ang('DMS2D',1001010.11);

switch key,
    case 'DMS2D',
        L=varargin{1}<0;varargin{1}(L)=-varargin{1}(L);
        varargout{1}=fix(varargin{1}./10000)+fix(mod(varargin{1},10000)./100)./60+mod(varargin{1},100)./3600; %DDDMMSS.SSS-->DD.DDDDD
        varargout{1}(L)=-varargout{1}(L);
    case 'D2DMS',
        L=varargin{1}<0;varargin{1}(L)=-varargin{1}(L);
        varargout{1}=fix(varargin{1}).*10000+(fix(mod(varargin{1},1).*60)).*100+mod(varargin{1}.*60,1).*60; %DD.DDDDD-->DDDMMSS.SSS
        varargout{1}(L)=-varargout{1}(L);
    case 'DMS32D', varargout{1}=varargin{1}+varargin{2}./60+varargin{3}./3600; %D,M,S-->DD.DDDDD
    case 'D2DMS3',
        L=varargin{1}<0;varargin{1}(L)=-varargin{1}(L);
        varargout{1}=fix(varargin{1});varargout{2}=fix(mod(varargin{1},1).*60);varargout{3}=mod(varargin{1}.*60,1).*60;%DD.DDDDD-->D,M,S
        varargout{1}(L)=-varargout{1}(L);varargout{2}(L)=-varargout{2}(L);varargout{3}(L)=-varargout{3}(L);
    case 'DM2D',
        L=varargin{1}<0;varargin{1}(L)=-varargin{1}(L);
        varargout{1}=fix(varargin{1}./100)+mod(varargin{1},100)./60; %DDDMM.MMM-->DD.DDDDD
        varargout{1}(L)=-varargout{1}(L);
    case 'D2DM',
        L=varargin{1}<0;varargin{1}(L)=-varargin{1}(L);
        varargout{1}=fix(varargin{1}).*100+mod(varargin{1},1).*60; %DD.DDDDD-->DDDMM.MMM
        varargout{1}(L)=-varargout{1}(L);
    case 'D2R', varargout{1}=varargin{1}./180.*pi; %DD.DDDD-->RR.RRRR
    case 'R2D', varargout{1}=varargin{1}./pi.*180; %RR.RRRR-->DD.DDDD
    otherwise, error('Error gNavAng2Ang: invalid key');
end;

%mail@ge0mlib.com 10/08/2017