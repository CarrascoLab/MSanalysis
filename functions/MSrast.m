function [ varargout ] = MSrast( tStruct, lock, wB4 ) %   , sortBy
% pass a structure of trial info - tStruct
% pass an int  N of the lock point events
% pass wB4 - time in MS to extend the analysis before the lock
% plots a raster for each trial with a line at each point flagged as a MS 

% pass sortBy : 1= by cue duration, 2=by cue onset, 3=  length after lock

assert(isstruct(tStruct))
    
    switch lock==0
        case true
            wB4=0;
            [tStruct.lockOn]=feed({tStruct.EMon});
            tOmega=max(need(tStruct, '',7,'events'));
            [~,i]=sort(need(tStruct, '',7,'events')); % sort it by trial length
        case false
            [tStruct.lockOn]=feed(cellfun(@(on,tZero) on-tZero,...
                {tStruct.EMon}', num2cell(need(tStruct, '',lock,'events')), 'uniformoutput', false));
            tAlpha=max(need(tStruct, '',lock,'events'));
            tOmega=max(need(tStruct, '',7,'events')-need(tStruct, '',lock,'events') );
%             
            if wB4>tAlpha, wB4=tAlpha; end % window before cue included
            
            [~,i]=sort(need(tStruct, '',7,'events')-need(tStruct, '',lock,'events')); % sort it by trial length

    end

    
    
%     switch sortBy
%         case 1
%             [~,i]=sort([tStruct.tarOn]-[tStruct.pcueOn]); % sort it by length of pcue  i.e., true SOA
%         case 2
%             [~,i]=sort([tStruct.pcueOn]); % sort it by cue onset
%         case 3
%             if ~strcmp (lock, 'start')
%                 [~,i]=sort([tStruct.trEnd]-[tStruct.(lock)]); % sort it by trial length
%             else
%                 [~,i]=sort([tStruct.trEnd]); % sort it by duration after lock 
%             end
%     end
    tStruct=tStruct(i);
    
    remIndx=cellfun(@(onX) onX>-wB4, {tStruct.lockOn},'UniformOutput', false); %
    pMat=nan(tOmega+wB4,length(tStruct));
    
    for tr=length(tStruct):-1:1
        % flag all timepoints in the duration of MSs within the analysis period 
        flagIndx=cell2mat(arrayfun( @(on,onFor) (on:on+onFor)+wB4, ...
            tStruct(tr).lockOn(remIndx{tr}), tStruct(tr).EMdur(remIndx{tr}),'UniformOutput', false)); 
        pMat(flagIndx,tr)=tr;
    end
    plot(1-wB4:tOmega, pMat,'k','lineWidth',.25)
    hold on
    
    
    plot([0 0],[1 length(tStruct)], 'r','lineWidth',2.5) % lock time  
    
    for ev=1:length(tStruct(1).events)
        
        if lock==0
            plot (need(tStruct,'',ev,'events'), 1:length(tStruct)) % event onsets
        elseif ev~=lock
            plot (need(tStruct,'',ev,'events')-need(tStruct,'',lock,'events'), 1:length(tStruct)) % event onsets
        end
    end
%     switch lock
%         case 'pcueOn'
%             plot([0 0],[1 length(tStruct)], 'b','lineWidth',2.5) % cue onsets
%             plot ([tStruct.tarOn]-[tStruct.pcueOn],1:length(tStruct), '.g','MarkerSize',5) % target onsets
%             plot ([tStruct.trEnd]-[tStruct.(lock)],1:length(tStruct), '.r','MarkerSize',6) % target onsets
%         case 'tarOn'
%             plot([0 0],[1 length(tStruct)], 'g','lineWidth',2.5) % target onsets
%             plot ([tStruct.pcueOn]-[tStruct.tarOn],1:length(tStruct), '.b','MarkerSize',5) % cue onsets
%             plot ([tStruct.trEnd]-[tStruct.(lock)],1:length(tStruct), '.r','MarkerSize',6) % target onsets
%         case 'start'
%             plot([tStruct.pcueOn],1:length(tStruct),'.b','MarkerSize',5)
%             plot([tStruct.tarOn],1:length(tStruct),'.g','MarkerSize',5)
%             plot ([tStruct.trEnd],1:length(tStruct), '.r','MarkerSize',6) % target onsets
%     end



    xlim([-wB4 tOmega])
    ylim([1 length(tStruct)])
    
    if nargout >=1       
    varargout{1}=pMat;
    end

hold off
end

