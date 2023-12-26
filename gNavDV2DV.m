function varargout=gNavDV2DV(key,varargin)
%Convert distance/speed format varargin{1} to distance/speed format varargout{1} accordance key.
%function varargout=gNavDV2DV(key,varargin), where
%varargin- converted distance/speed;
%varargout- conversion distance/speed;
%key- formats key: inch2m, m2inch, mile2m, m2mile, knot2ms, ms2knot, kmh2ms, ms2kmh (mile is 1852m).
%Example: D=gNavDV2DV('mile2m',10.1);

switch key,
    case 'inch2m', varargout{1}=varargin{1}./2.54/1000;
    case 'm2inch', varargout{1}=varargin{1}.*2.54*1000;
    case 'mile2m', varargout{1}=varargin{1}.*1852;
    case 'm2mile', varargout{1}=varargin{1}./1852;
    case 'knot2ms', varargout{1}=varargin{1}./3600.*1852;
    case 'ms2knot', varargout{1}=varargin{1}.*3600./1852;
    case 'kmh2ms', varargout{1}=varargin{1}./3.600;
    case 'ms2kmh', varargout{1}=varargin{1}.*3.600;
    otherwise, error('Error gNavDV2DV: invalid key');
end;

%mail@ge0mlib.com 10/08/2017