function [ indx, levs ] = factIndx(TRials, factors )
% accepts a data struct (TRials) and a cell string-array of field names (factors)
% identifies unique levels of the factor and creates a logical index of
% TRials correspending with each level of each factor 
% Output: returns indx & levs, two structures containing the indexes and
% levels respectively of each factor in a field of the same name. 

assert (isstruct(TRials))
assert (iscell(factors))
assert(all(isfield(TRials, factors)))

for f=1:length(factors)
    if ischar(TRials(1).(factors{f}))
            levs.(factors{f})=unique({TRials.(factors{f})});
            st=true;
        else
            levs.(factors{f})=  num2cell(unique([TRials.(factors{f})]));
            %cellstr(num2str(unique([TRials.(factors{f})])'))'; % <<< - this is soooooo ugly lol
            st=false;
    end
    nLevs=length(levs.(factors{f}));
    
%    if st
%        indx.(factors{f})= cellfun (@(lvl) strcmp (levs.(factors{f})(lvl),[TRials.(factors{f})])', num2cell(1:nLevs)', 'uniformoutput', false);
%    else
%        indx.(factors{f})= cellfun (@(lvl) levs.(factors{f}){fL}==[TRials.(factors{f})]', num2cell(1:nLevs)', 'uniformoutput', false);
%    end
   
    indx.(factors{f})=cell(nLevs,1);
    for fL=1:nLevs
        if st
            indx.(factors{f}){fL}=strcmp(levs.(factors{f})(fL), {TRials.(factors{f})})';
        else
            indx.(factors{f}){fL}=levs.(factors{f}){fL}==[TRials.(factors{f})]';
        end
    end
end
