function fXY= zPhFilt(data, sRateRatio)
% function to filter eyelink data
% generates a finite impulse response filter and uses it to filter the data
% with zero phase offset. 
% data may be an array of any number of columns
% sRateRatio should be either a scalar or a vector of length nColumns
% sRateRatio should be the ratio 1000/sample-frequency (hz)

cols=size(data,2);
fXY=zeros(size(data));

if ~(length(sRateRatio)==cols) && length(sRateRatio)==1
    sRateRatio=ones(cols,1)*sRateRatio;
else
    error(' inappropriate sRateRatio vector... \n length(sRateRatio) must equal 1 or the number of columns in the data', 'mismatch')
end 


% filter data 
for i=1:cols
    
fXY(:,i)=filtfilt(fir1(35,0.05*sRateRatio(i)),1,data(:,i));% zero phase digital filter & FIR (gaussian) 

end