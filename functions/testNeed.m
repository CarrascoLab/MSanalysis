TemON=cell(size(lAttice)); % cell of trials with an MS flag at each position of lAttice (i.e., t-lock)

for trialN= 1:length(sElect)
    for emOnOff=[sElect(trialN).EMon;sElect(trialN).EMoff];
        for t=emOnOff(1): emOnOff(2)
            TemON{t}(end+1)=trialN;
        end
    end
end