function [ varargout ] = mainSeq( dataStruct, MsStruct )
% plots basic EM kinematics & main sequence 
    figure
    
    MSaxes=cell(2,2);

    msInd=[dataStruct.MScrit];
    a=[dataStruct.amp] ;v=[dataStruct.vPeak] ; d= [dataStruct.EMdur];
    
    MSaxes{1}=subplot(2,2,1);
    % main sequence
    scatter(MSaxes{1},a(msInd),v(msInd),40,[.6 .6 .6],'marker','.');
    set(MSaxes{1},'XScale','log','YScale','log')
    title('Main Sequence')
    xlabel('Amplitude (º)')
    ylabel('Peak Vel. (º/s)')
    xlim([MsStruct.amp.min-.01 MsStruct.amp.max+1])
    
    MSaxes{2}= subplot(2,2,2);
    % MS Amplitude
    hist(MSaxes{2},a(msInd),100);
    set(MSaxes{2}.Children,'FaceColor',[.8 .8 .8],'EdgeColor',[.6 .6 .6])
    
    title('Amplitude')
    xlabel('Amplitude (º)')
    ylabel('Frequency')
    
    MSaxes{3}= subplot(2,2,3);
    % Peak Velocity of MS
    hist(MSaxes{3},v(msInd),100);
    set(MSaxes{3}.Children, 'FaceColor',[.8 .8 .8],'EdgeColor',[.6 .6 .6])
    
    title('Peak Velocity')
    xlabel('Peak Vel. (º/s)')
    ylabel('Frequency')
    
    MSaxes{4}=subplot(2,2,4);
    % MS duration
    hist(MSaxes{4},d(msInd),100);
    set(MSaxes{4}.Children,'FaceColor',[.8 .8 .8],'EdgeColor',[.6 .6 .6])
    
    title('Duration')
    xlabel('Duration (ms)')
    ylabel('Frequency')

    if nargout
        varargout{1}=MSaxes;
    end
end

