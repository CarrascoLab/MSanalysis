function [ rate, scale ] = getMSrate(TRials, lock)
% MSrate
%   input: tStruc -1xN structure array, selected from TRials
%              lock - string corresponding with a field in TRials
%                   ** if lock ==0, locked on t=0 (trial start) **
% if MScrit is a field, the logical indexes therein will determine which EM
% are included in the analysis of rate
%

nEvents=length(TRials(1).events);
endArray=need(TRials, '',nEvents,'events'); % trial endpoints

% set wb, wa & nt
if lock==0 % from start point
    windBefore=-1;
    windAfter= max(endArray); % window after
    nOfTrials=sum( endArray*ones(1,windAfter) > ones(size(endArray))*(1:windAfter) );% count trials at each time point
    
    MSonsets=[TRials.EMon];
    
    
elseif lock>0&&lock<=nEvents% with lockpoint centered
    lockArray=need(TRials, '',lock,'events'); % lock points
    windBefore= max(lockArray)-1; % window before lock
    windAfter= max(endArray-lockArray); % window after lock
    nOfTrials=ones(size(endArray))*(-windBefore:windAfter); % just initializing nt
    nOfTrials=sum((endArray-lockArray)* ones(1,size(nOfTrials,2)) > nOfTrials & nOfTrials > (-lockArray)*ones(1,size(nOfTrials,2))) ; % count trials at each time point
    
    temp=cellfun(@(pX,X) (pX(:)'-X(:)), {TRials.EMon}, num2cell(lockArray)','UniformOutput',false);
    MSonsets=[temp{:}];
    
else
    error('inappropriate event-lock number passed')
end

% crop to EM satisfying MS criteria
if isfield(TRials, 'MScrit')
    MSonsets= MSonsets([TRials.MScrit]);
end

% calculate rate & scale
[rate, scale] = causRate(MSonsets,windBefore,windAfter,nOfTrials);

            % % identify range where >20% of trials contribute 
            % if lock==0
            %     lims=[1  find(nOfTrials< (max(nOfTrials)*1/5),1,'first')];
            % else
            %     lims= [find(scale'<0 & nOfTrials<(max(nOfTrials)*1/5),1,'last'), find(scale'>0 & nOfTrials<(max(nOfTrials)*1/5),1,'first')];
            %     lims= scale(lims)';
            % end

% trim NaN value at end
rate=rate(1:end-1)';
scale=scale(1:end-1)';
end

