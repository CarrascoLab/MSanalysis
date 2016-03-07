function [rate, scale] = causRate(msOns,wbLock,waLock,nt)
%
% analyse rate in causal time window
%
% input:    msOns   - microsaccade onset times
%           wbLock  - window before lock
%           waLock  - window after lock
%           nt      - number of trials
%
% output:   rate    - microsaccade rate
%           scale   - time axis
%
% 12.12.2005 by Martin Rolfs

if length(nt)==1
    nt = linspace(nt,nt,length((-wbLock:waLock)));
elseif length(nt)~=length(-wbLock:waLock)
    error('nt must have the same length as -wbLock:waLock!')
end
    
alpha = 1/20;
scale = [];
rate = [];
for t=-wbLock:waLock
    scale = [scale; t];
    tau = t-msOns+1/alpha;
    tau = tau(tau>0);
    causal = alpha^2*tau.*exp(-alpha*tau);
    rate = [rate; sum(causal)*1000/nt(length(scale))];
end
