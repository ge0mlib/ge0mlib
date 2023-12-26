function Data1=gDataTraceWeight(Data,wk,normFl)
%Weighting traces/columns group (rows filtering) with slice-window (includes filter’s coefficients).
%function Data1=gDataTraceWeight(Data,wk,normFl), where
%Data- input matrix with traces; Data(trace_length,trace_num);
%wk- average filter coefficients;
%normFl- normalization flag; if normFl~=0, than wk=wk./sum(wk);
%Data1- output matrix with traces.
%Example: wk1=gausswin(12,3);Data1=gDataTraceWeight(Data,wk1,normFl); %wk1=gausswin(N,Alpha);wk2=chebwin(L,r);wk3=blackman(N,SFLAG);wk4=blackmanharris(N,SFLAG);

wk=wk(:)';
if normFl~=0, wk=wk./sum(wk);end;
lw=length(wk)-1;lw2=fix(length(wk)./2+1e-6);
s=size(Data);Data1=nan(s);w_k=repmat(wk,s(1),1);
for nz=1:s(2)-lw, Data1(:,nz+lw2)=sum(Data(:,nz:nz+lw).*w_k,2);end;

%mail@ge0mlib.com 18/08/2016