function st = variablePoissonSpikeTrain(minRate,maxRate,maxChangeSpeed,T,dt,maxTimeWithoutSpike)
% Returns a list of times when input nodes/neurons will fire. Each affernt
%    needs its own list.
% INPUTS:
%    minRate=10
%    maxRate=10
%    maxChangeSpeed=0
%    T  - total time duration = 225
%    dt - signal sampling interval =0.001
%    maxTimeWithoutSpike =Inf
% OUTPUTS:
%    st
% PARAM.spontaneousActivity=10,PARAM.spontaneousActivity=10,0,PARAM.T=225,PARAM.dt=1e03,Inf);

st = [];
virtualPreSimuSpike = -rand*maxTimeWithoutSpike; % Tim 09/2007 : avoids clusters of spikes when t=maxTimeWithoutSpike
% virtualPreSimuSpike = 0; % just for compatibility with previous simu

rate = minRate + rand * (maxRate-minRate);  % constant if minRate==maxRate

rateChange = 2*(rand-.5)*maxChangeSpeed;

% tmp = [];
mtws = (1-.0*rand)*maxTimeWithoutSpike;

for t=dt:dt:T
    if  rand < dt * rate || ...
        (isempty(st) && t-virtualPreSimuSpike>mtws) || ...
        (~isempty(st) && t-st(end)>mtws)
%         st = [st t];
        tmp = t-dt*rand;
        tmp = max(0,tmp);
        tmp = min(T,tmp);
        st = [st tmp];
        mtws = (1-.0*rand)*maxTimeWithoutSpike;
    end
    
%     rate = rate + 2*(rand-.5)*maxChangeSpeed*dt;
    
    rate = rate + rateChange*dt;
    rateChange = rateChange + 1/5*2*(rand-.5)*maxChangeSpeed;
    rateChange = max(min(rateChange,maxChangeSpeed),-maxChangeSpeed);
    
    rate = max(min(rate,maxRate),minRate);    
%     tmp = [tmp rate];

%     plot(st',ones(1,length(st)),'x')  % times when neurons will fire.
end


% % figure
% plot(dt:dt:T,tmp);
% axis([0 2 0 100]);
% pause
