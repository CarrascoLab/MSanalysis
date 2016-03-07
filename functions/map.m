function [ Centers,Values ] = map( data,nBins )
%Map - plot MS direction as a function of time.
%   data: MS directions, sorted by time
% nBins: how the polar histogram is divied 
%


if iscell(data)
    bins=cell(size(data));
    [bins{:}]=deal(nBins);
    [binPts,binVals]=cellfun(@rose,data,bins,'uniformoutput',false);
    Centers=(binPts{1}([2:4:end])+binPts{1}([3:4:end]))/2;
    Normed=cell2mat(cellfun(@(Vs) (Vs([2:4:end ])/sum(Vs(2:4:end)))',binVals,'uniformoutput',false));
    Values=cell2mat(cellfun(@(Vs) (Vs([2:4:end ]))',binVals,'uniformoutput',false));
elseif ismatrix(data)
    bins=nBins;
[binPts,binVals]= rose (data,bins);

Centers=(binPts([2:4:end 2])+binPts([3:4:end, 3]))/2;
Normed=binVals([2:4:end 2])/sum(binVals(2:4:end));
Values=binVals([2:4:end 2]);

end

% polar(Centers,Normed,'ro-') 
end

