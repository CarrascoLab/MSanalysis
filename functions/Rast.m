function Rast(trStruct, lock, wBefore)
% specific to TRstruct format must contain fields: trEnd, EMon, EMdur
% lock must also be a field within the struct
% wBefore, is the period before the lock to include in the plot 

% additional arguments accepted :
% 'wBefore', double (ms)
% 'clip', string (field name) - default 'trEnd'
% 'wAfter', double

wBefore= wBefore/1000 ; % window beofore lock point

mDUR=round(median([trStruct.EMdur]))/1000;
% useful locks: 'tarOn', 'pcueOn', 'trEnd'

clip='trEnd';

% lock='pcueOn';
LEI=[trStruct.(clip)]-[trStruct.(lock)]; %lock:end interval for each trial
% CTI=[[trStruct.trEnd]-[trStruct.(lock)]];
[~,i]=sort(LEI,'descend'); % for ordering trials by length
m=cell(length(trStruct),1);
for trial = 1: length(trStruct)
    MSs=([trStruct(i(trial)).EMon]-[trStruct(i(trial)).(lock)])./1000;
    MSs= MSs(MSs>-wBefore);
    m{trial}=MSs;
end
nullM=cell2mat(arrayfun(@(trial) isempty([m{trial}]), 1:length(m),'uniformoutput', false)); % index of trials with no
m(nullM)={nan};

% [x,y]=
plotSpikeRaster(m,'SpikeDuration',mDUR); %(~nullM)
hold on
plot(LEI(i)./1000, (1:length(i)), 'r' ) %(~nullM)
hold off
end