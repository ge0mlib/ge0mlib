function [Data,tk]=gDataGainPL(Data,tp,k,frL,mm)
%Traces/pings Gain.
%[Data,tk]=gDataGainPL(Data,tp,k,frL), where
%Data- input matrix with traces; Data(trace_length,trace_num);
%tp- gain method ID: 'lg', 'exp', 'agc', 'pow';
%k- gain method coefficients;
%frL- gain from polyline: 1)polyline struct; 2)two rows polyline [trace_number; current_trace's_point_number]; 3)scalar; 4)one rows polyline current_trace's_point_number for all traces;
%mm- max for gain;
%Data- output matrix with traces.
%tk- gain coefficients.
%================================
%'nn' method: Data=Data*weight;weight=At+B; k=[A B].
%'pow' method: Data=Data*weight;weight=(t*A)^B << k=[A B].
%'lg' method: Data=Data*weight;weight=At+20Blg(t)+C; k=[A B C dt].
%'exp' method: Data=Data*weight;weight=At*exp(Bt)+C; k=[A B C dt]. If k(1)==0, than used out=exp(Bt)+C.
%'agc' method: Data=Data/weight;weight=sum(abs(k*win))/nwin. k=[k1...kn] weight coefficients. frL not used.
%'agc_pow' method: Data=Data/weight;weight=sqrt(sum((k*win)^2))/nwin. k=[k1...kn] weight coefficients. frL not used.
%Example:
%wk1=gausswin(200,3);wk2=chebwin(L,r);wk3=blackman(N,SFLAG);wk4=blackmanharris(N,SFLAG);[Data1,~]=gDataGainPL(Data,'agc',wk1,[],[]);
%[Data1,~]=gDataGainPL(Data,'exp',[0 0.001 0 1],30,[]);[Data1,tp]=gDataGainPL(Data,'lg',[0 0.2 1 10 1],30,[]);

sData2=size(Data,2);
if isempty(frL), frL=[1:sData2;ones(1,sData2)];
elseif all(isnumeric(frL))&&(numel(frL)==1), frL=[1:sData2;repmat(frL,1,sData2)];
elseif all(isnumeric(frL))&&(numel(frL)==sData2), frL=[1:sData2;frL(:)'];
elseif isstruct(frL), frL=frL.PickL;
else error('frL parameter error.');
end;

switch tp,
    case 'nn', %Data=Data*weight;weight=At+B << k=[A B]
        sz=size(Data,1);nn=(1:sz)./sz;
        tk=(k(1).*nn+k(2))';if ~isempty(mm),tk(tk>mm)=mm;end;
        for nz=1:size(frL,2),
            n=frL(1,nz);
            Data(frL(2,nz):sz,n)=Data(frL(2,nz):sz,n).*tk(1:(sz-frL(2,nz)+1));
        end;
    case 'pow', %Data=Data*weight;weight=(t*A)^B << k=[A B]
        sz=size(Data,1);nn=(1:sz)./sz;
        tk=((k(1).*nn).^k(2))';if ~isempty(mm),tk(tk>mm)=mm;end;
        for nz=1:size(frL,2),
            n=frL(1,nz);
            Data(frL(2,nz):sz,n)=Data(frL(2,nz):sz,n).*tk(1:(sz-frL(2,nz)+1));
        end;
    case 'lg', %Data=Data*weight;weight=At+20B*lg(t*m)+C << k=[A B m C]
        sz=size(Data,1);nn=1:sz;
        tk=(k(1).*nn+20.*k(2).*log(nn*k(3))+k(4))';if ~isempty(mm),tk(tk>mm)=mm;end;
        for nz=1:size(frL,2),
            n=frL(1,nz);
            Data(frL(2,nz):sz,n)=Data(frL(2,nz):sz,n).*tk(1:(sz-frL(2,nz)+1));
        end;
    case 'exp', %Data=Data*weight;weight=At*exp(Bt)+C << k=[A B C dt]
        sz=size(Data,1);nn=1:sz;
        if k(1)==0, tk=(exp(k(2).*nn)+k(3))'; else tk=(k(1).*nn.*exp(k(2).*nn)+k(3))';end;if ~isempty(mm),tk(tk>mm)=mm;end;
        for nz=1:size(frL,2),
            n=frL(1,nz);
            Data(frL(2,nz):sz,n)=Data(frL(2,nz):sz,n).*tk(1:(sz-frL(2,nz)+1));
        end;
    case 'agc', %Data=Data/weight;weight=sum(abs(k*win))/nwin << k=[k1...kn]
        tk=k(:);tk=tk./sum(tk);
        lw=length(tk)-1;lw2=fix(length(tk)./2+1e-6);
        sz=size(Data);Data1=nan(sz);w_k=repmat(tk,1,sz(2));
        for nz=1:sz(1)-lw, 
            Data1(nz+lw2,:)=sum(abs(Data(nz:nz+lw,:).*w_k));
        end;
        Data=Data./(Data1./length(tk));
    case 'ags_pow', %Data=Data/weight;weight=sqrt(sum((k*win)^2))/nwin << k=[k1...kn]
        tk=k(:);tk=tk./sum(tk);
        lw=length(tk)-1;lw2=fix(length(tk)./2+1e-6);
        sz=size(Data);Data1=nan(sz);w_k=repmat(tk,1,sz(2));
        for nz=1:sz(1)-lw, 
            Data1(nz+lw2,:)=sum((Data(nz:nz+lw,:).*w_k).^2);
        end;
        Data=Data./(sqrt(Data1)./length(tk));
    otherwise
        error('Unidentified Gain method.');
end;

%mail@ge0mlib.com 18/10/2016