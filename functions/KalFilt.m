function filt_xy = KalFilt (xy_pos)
% uses code from microsacc_detection.m, combining a Kalman filter and Engbert and
%Kliegl 2003 by Andra Mihali, Ma Lab, 2015.
% functionized by NMS July 2015 
% Takes as input :  x [n,2] - gaze position offset from center in pixels 
% Returns as output : xf [n,2] - the filtered gaze position in the same
% units

%general params for Kalman filter
%approximately what we fit to the Eyelink data. could play around with
%them, but results shouldn't differ much
% 
% sigz=0.005;  %motor noise of the eye
% sigx=0.025;   %measurement noise of the eye tracker
% 
% Ez =sigz^2*eye(2); %covariance matrix for process
% Ex =sigx^2*eye(2); %covariance matrix for measurement
% 
% P=(-Ez+sqrt(Ez.^2+4*Ez*Ex))/2;  %estimate error covariance
% K=(P+Ez)*inv(P+Ez+Ex);  %Kalman gain factor that minimizes the estimate error covariance

% ? is this fine?
K=[ .181 0; 0 .181];
filt_xy=zeros(size(xy_pos));

filt_xy(1,:)=xy_pos(1,:);
for t = 2:length(xy_pos)
    filt_xy(t,:)=(filt_xy(t-1,:)'+K*(xy_pos(t,:)-filt_xy(t-1,:))')';
    
end

end
