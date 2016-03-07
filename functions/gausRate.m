function [rate, scale] = gausRate(msOns,wbLock,waLock,nt)
%
% analyse rate in gaussian time window
%
% input:    msOns   - microsaccade onset times
%           wbLock  - window before lock
%           waLock  - window after lock
%           nt - scalar # of trials or vector # of trials for each time
%           point (-wb:wa)
% output:   rate    - microsaccade rate
%           scale   - time axis
%
% 12.12.2005 by Martin Rolfs

if length(nt)==1 % i.e., same number of trials throughout
    nt = linspace(nt,nt,length((-wbLock:waLock))); 
elseif length(nt)~=length(-wbLock:waLock)
    error('nt must have the same length as -wbLock:waLock!')
end
    
sigma = 10;
scale = [];
rate = [];
for t=-wbLock:waLock
    scale = [scale; t];
    tau = t-msOns;
    gauss = 1/(sqrt(2*pi)*sigma)*exp(-tau.^2/(2*sigma^2));
    rate = [rate; sum(gauss)*1000/nt(length(scale))];
end
