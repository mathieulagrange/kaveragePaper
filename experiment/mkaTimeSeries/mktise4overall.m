function [config, store, obs] = mktise4overall(config, setting, data)
% mktise4overall OVERALL step of the expLanes experiment mkaTimeSeries
%    [config, store, obs] = mktise4overall(config, setting, data)
%      - config : expLanes configuration state
%      - setting   : set of factors to be evaluated
%      - data   : processing data stored during the previous step
%      -- store  : processing data to be saved for the other steps
%      -- obs    : observations to be saved for analysis

% Copyright: Mathieu Lagrange
% Date: 03-Dec-2015

% Set behavior for debug mode
if nargin==0, mkaTimeSeries('do', 4, 'mask', {0 1 2 [1 2 8 9] [3] [1] 2 1}); return; else store=[]; obs=[]; end

% imported data
loadedObs = expLoad(config, [], 3, 'obs');

obs.nmi = [loadedObs.nmi];
obs.accuracy = [loadedObs.accuracy];