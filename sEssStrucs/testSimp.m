
    [i,j,v]=deal(zeros(1,sum([sElect.EMdur])));
    cnt=1;
    for nT= 1:length(sElect) % for each trial
        %         emOnOff=[sElect(nT).EMon;sElect(nT).EMoff]+(WBmax-sElect(nT).events(lock)); % start and end points of eye-movements in lAttice coordinates
        for emN=1:sElect(nT).numEM
            %             section=max(emOnOff(1,emN)-halfWindow,1): min(emOnOff(2,emN)+halfWindow,length(lAttice)); % duration of EM + window
            section=(sElect(nT).EMon(emN):sElect(nT).EMoff(emN))... % duration of EM
                +(WBmax-sElect(nT).events(lock)); %adjusted by lock time
            dur=length(section);
            if ~dur==sElect(nT).EMdur(emN)
                sprintf('Prob! t:%i\tem:%i',nT, emN)
            end
            i(cnt:cnt+dur-1)=ones(1,dur)*nT;    % row index
            j(cnt:cnt+dur-1)=section;                % column index
            v(cnt:cnt+dur-1)=ones(1,dur)*sElect(nT).(polarAng{typeAng})(emN); % sacDir values
            
            plot((cnt:cnt+dur-1)',nT,'o'),hold on, drawnow
            cnt=cnt+dur;
            %             sacc(nT,section)=true;
            %             saccDir(nT,section)= sElect(nT).(polarAng{typeAng})(emN); %catDir( sElect(nT).(polarAng{typeAng})(emN), sElect(nT).diagonal, sElect(nT).locTarg);
            
        end
%         cnt
    end
    
%     saccDir=sparse(i,j,v,length(sElect), length(lAttice));