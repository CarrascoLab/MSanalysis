function [ varargout ] = plotEvents ( daStruc, lock, before, after,labels )
% provide data structure
% labels
% event lock number
% & xlims
assert(isstruct(daStruc))
nEvents=length(daStruc(1).events);
assert (lock<= nEvents)
hold on
hLine=cell(1,nEvents-1);
for ev=1:nEvents-1
    if lock==0
        t=daStruc(1).events(ev);
    elseif ev~=lock
        t=daStruc(1).events(ev)-daStruc(1).events(lock);
    elseif ev==lock
        t=0;
    end
    
    if t>-before && t<after
        hLine{ev}=plot([t t], [ylim],'--k', 'linewidth',.5);
        if ~isempty(labels)
            hText{ev}=text (t-20,max(ylim)-diff(ylim)*.25, ['\bf',labels{ev}],'Rotation',90,'FontSize',16);
        end
    end
    
    
end
switch nargout
    case 0
        
    case 1
        varargout={hLine};
    case 2
        
        if ~isempty(labels)
            varargout={hLine,hText};
        else
            varargout={hLine};
        end
        
end
end

