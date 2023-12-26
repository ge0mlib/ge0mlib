 function varargout=gNavCoordDerepeat(varargin)
%Remove and interpolate repeating (and NaN) position [E,N] or time/position [Day,Second,E,N]. Reasonable to use for data with constant time-step measurements.
%function [Er,Nr]=gNavCoordInterp(E,N,meth) or [Dr,Sr,Er,Nr]=gNCoordInterp(D,S,E,N,meth) where
%varargin=[E,N,meth] or [Dm,S,E,N,meth] >>
%E,N– rows, Easting, Northing in meters;
%Dm,S- serial date number of 1 corresponds to Jan-1-0000 and second per day;
%meth - interpolation method ('linear','pchip', etc);
%varargout=[Ei,Ni] or [Dmi,Si,Ei,Ni] >>
%E,N– rows, Easting, Northing in meters were interpolated;
%Dm,S- serial date number of 1 corresponds to Jan-1-0000 and second per day were interpolated;
%Function Example: [Er,Nr]=gNavCoordDerepeat([1 2 2 3 3 4 5 6],[1 1 1 2 3 4 5 5],'linear');[Di,Si,Ei,Ni]=gNavCoordDerepeat([95 95 95 95 95 95 95 95],[1 2 2 4 5 6 7 8],[1 2 2 3 3 4 5 6],[1 1 1 2 3 4 5 5],'linear');

if length(varargin)==3,
    %E=varargin{1};N=varargin{2};meth=varargin{3};
    z=1:size(varargin{1},2);
    L=[true any(abs(diff([varargin{1};varargin{2}],1,2))>[eps(diff(varargin{1}));eps(diff(varargin{2}))])];
    L=L&~isnan(varargin{1})&~isnan(varargin{2});%nan
    varargout{1}=interp1(z(L),varargin{1}(L),z,varargin{3},'extrap');
    varargout{2}=interp1(z(L),varargin{2}(L),z,varargin{3},'extrap');
end;
if length(varargin)==5,
    %D=varargin{1};S=varargin{2};E=varargin{3};N=varargin{4};meth=varargin{5};
    z=1:size(varargin{1},2);
    [Dm,S]=gNavTime2Time('DxSd2DmS',varargin{1},varargin{2});
    L=[true abs(diff(S))>eps(diff(S))];
    if ~isempty(varargin{3}), L=L&~isnan(varargin{3});end;
    if ~isempty(varargin{4}), L=L&~isnan(varargin{4});end;
    Sr=interp1(z(L),S(L),z,varargin{5},'extrap');
    if ~isempty(varargin{3}), varargout{3}=interp1(S(L),varargin{3}(L),Sr,varargin{5},'extrap'); else varargout{3}=[];end;
    if ~isempty(varargin{4}), varargout{4}=interp1(S(L),varargin{4}(L),Sr,varargin{5},'extrap'); else varargout{4}=[];end;
    [varargout{1},varargout{2}]=gNavTime2Time('DmS2DxSd',Dm,Sr);
end;

%mail@ge0mlib.com 17/10/2016