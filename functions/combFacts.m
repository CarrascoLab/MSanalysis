function [ Constraints, legendEntries ] = combFacts(TRials, constFactors)
% accepts a struct and a cell- string array of field names (factors),
% outputs a cell of logical indexes combining the factors 

assert (isstruct(TRials))
assert (iscell(constFactors))
assert(all(isfield(TRials, constFactors)))
if length (constFactors)>1
    % gather individual constraints
    for f=length(constFactors):-1:1
        if ischar(TRials(1).(constFactors{f}))
            levs{f}=unique({TRials.(constFactors{f})});
        else
            levs{f}=cellstr(num2str(unique([TRials.(constFactors{f})])'))'; % <<< - this is soooooo ugly lol
        end
        Nlevs{f}=length(levs{f});
        [Cons{f}, ~] =combFacts(TRials, constFactors(f)); % recursion!
    end
    % Constraints has length(cFacts) dims & size [Nlevs i, ...] for each cFact
    Constraints=cell(Nlevs{:});
    legendEntries=cell(Nlevs{:});
    subscripts=cell(1,ndims(Constraints));
    temp=[];
    for i=numel(Constraints):-1:1
        [subscripts{:}]=ind2sub([Nlevs{:}],i); % because we're not sure of ndims
        %         get individual constraints
        temp=cellfun(@(c,s) c{s},Cons,subscripts,'uniformoutput',false);
        % identify trials matching all individual constraints
        Constraints{i}=sum([temp{:}],2)==ndims(Constraints);
        for f=1:ndims(Constraints)
            if f==1
                legendEntries{i}= sprintf('%s: %s', constFactors{f}, levs{f}{subscripts{f}});
            else
                legendEntries{i}=sprintf('%s & %s: %s', legendEntries{i}, constFactors{f}, levs{f}{subscripts{f}});
            end
        end
    end
elseif  length (constFactors)==1
    
    if ischar([TRials.(constFactors{1})])
        levs=unique({TRials.(constFactors{1})});
    else
        levs=num2cell(unique([TRials.(constFactors{1})]));
    end
    Nlevs=length(levs);
    for L=Nlevs:-1:1
        if ischar(TRials(1).(constFactors{1}))
            Constraints{L,1}=strcmp({TRials.(constFactors{1})}',levs{L});
            legendEntries{L,1}=sprintf('%s: %s', constFactors{1}, levs{L});
        else
            Constraints{L,1}=[TRials.(constFactors{1})]'==levs{L};
            legendEntries{L,1}=sprintf('%s: %d', constFactors{1}, levs{L});
        end
        
    end
end
end



