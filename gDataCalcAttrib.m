function Data=gDataCalcAttrib(Data,param)
%Calculate "attributes" for data-matrix (along traces/columns).
%function Data=gDataCalcAttrib(Data,param), where
%Data- input matrix with traces; Data(trace_length,trace_num);
%param- attributes parameters (the elements indexes are used as scale):
%instantaneous amplitude- param{1}=1; instantaneous phase- param{1}=2; instantaneous phase cosine- param{1}=3; instantaneous frequency- param{1}=1;
%envelope- param{1}=5, param{2..4}- use "help envelope".
%Data- output matrix with normalized traces;
%Example: Data1=gDataCalcAttrib(Data,{3});Data1=gDataCalcAttrib(Data,{1});

switch param{1},
    case 1, Data=abs(hilbert(Data));
    case 2, Data=angle(hilbert(Data));
    case 3, Data=cos(angle(hilbert(Data)));
    case 4, Data=diff(unwrap(angle(hilbert(Data))));
    case 5, if numel(param)==1, [Data,~]=envelope(Data);else [Data,~]=envelop(Data,param{2:end});end;
    otherwise, error('Error gDataCalcAttrib: param error');
end;

%mail@ge0mlib.com 20/10/2016