function [ ToPlot ] = prepToPlot( dataStruct, titles, factorsPlusGroupings, Labels )
% preps a structure for anaTRials etc.
% aside from the dataStruct each arg must be a [1Xn] cell 
% where n is the number of figures to be plotted 
% returns: ToPlot a struct with fields: 'titles', 'Indx','nGrps',
%  'group.conds', 'group.members' 
factFields=factorsPlusGroupings{1}; % seperate out factor field names 
groups=factorsPlusGroupings(2:end); % get group defining factors 
nFigs=length(titles); % number of seperate plots 
[ToPlot(1:nFigs).titles]=titles{:}; % assign titles to figures 
[cIndx, ~] =factIndx(dataStruct, {'obs', factFields{:}}); % get indexes for the different factor levels 

for fig=nFigs:-1:1
   ToPlot(fig).nGrps=size(groups{fig},1); % assign number of groups
   ToPlot(fig).Indx=false(ToPlot(fig).nGrps,length(dataStruct)); % initialize group indexes 
    for G= ToPlot(fig).nGrps:-1:1
    ToPlot(fig).group(G).conds=groups{fig}(G,:); % assign factor conditions to output struct 
        clear tempBool tLegs % clear temp variables 
%         tLegs=cell(1,length(factFields));
        for factor=length(factFields):-1:1
            tempBool{factor}= any(...   % get individual factor indexes 
                [cIndx.(factFields{factor}){groups{fig}{G,factor}}],...
                2);
            tLegs{factor}=sprintf('%s ',Labels.(factFields{factor}){[groups{fig}{G,factor}]} ); % and individual factor level labels 
        end
        ToPlot(fig).Indx(G,:)=all([tempBool{:}],2)'; % combine indexes 
        ToPlot(fig).group(G).members= unique({dataStruct(ToPlot(fig).Indx(G,:)).obs}); % identify group members 
        ToPlot(fig).group(G).nMems= length(ToPlot(fig).group(G).members);     % count the # of members 
        ToPlot(fig).legend{G}=sprintf('%s ', tLegs{:}); % combine labels for figure legend 
    end
end

