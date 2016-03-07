for tr=1:length(TRials)
    missing=find(TRials(tr).blinks(:,1));
    if ~isempty(missing)
        overWrite=false(size(TRials(tr).xy_pos));
        
        switch filtType
            case 1
                overWrite( missing,:)=true;
            case 2
                missing= arrayfun(@(MSN) MSN-blinkBorder:MSN+blinkBorder, missing,'uniformoutput', false);
                overWrite(unique([missing{:}]),:)= true;
            case 3
                missing= arrayfun(@(MSN) MSN:MSN+blinkBorder, missing,'uniformoutput', false);
                overWrite(unique([missing{:}]),:)= true;
        end
        
        if numel(overWrite)~=numel(TRials(tr).xy_pos)
            overWrite=overWrite(size(TRials(tr).xy_pos));
        end
        % place holders for time point when gaze position was lost
        TRials(tr).xy_filt(overWrite)=nan;
        TRials(tr).vel(overWrite)=nan;
    end
end
