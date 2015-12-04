function [config, store, obs] = mktise3max(config, setting, data)
% mktise3max MAX step of the expLanes experiment mkaTimeSeries
%    [config, store, obs] = mktise3max(config, setting, data)
%      - config : expLanes configuration state
%      - setting   : set of factors to be evaluated
%      - data   : processing data stored during the previous step
%      -- store  : processing data to be saved for the other steps
%      -- obs    : observations to be saved for analysis

% Copyright: Mathieu Lagrange
% Date: 02-Dec-2015

% Set behavior for debug mode
if nargin==0, mkaTimeSeries('do', 3, 'mask', {0 1 2 [5] [3] [1] 2 1}, 'parallel', 1); return; else store=[]; obs=[]; end % 1 2 [8 9 5] [3] [1] 2 1

dataOne = expLoad(config, [], 1, 'data');
if ~isempty(dataOne)
    dataOne.distance(dataOne.distance==Inf) = NaN;
    dataOne.distance(isnan(dataOne.distance)) = max(dataOne.distance(:));
    
    if isvector(dataOne.distance)
        S = squareform(dataOne.distance)-min(dataOne.distance);
        S = S/max(S(:));
        S = 1-S;
    else
        S = dataOne.distance;
        S = S-min(S(:));
        S = S/max(S(:));
    end
end

for k=1:size(data.clusters, 1)
    energy(k) = energy(S, data.clusters(k, :));
end

[em, ind] = min(energy);

% imported data
loadedObs = expLoad(config, [], 2, 'obs');

if ~isempty(loadedObs)
    obs.nmi = loadedObs.nmi(ind);
    obs.accuracy = loadedObs.accuracy(ind);
end


function e = energy(S, c)

if min(c)==0
    c=c+1;
end
nbc = max(unique(c));

e = zeros(1, nbc);
for k=1:size(S, 1)
    for l=k+1:size(S, 1)
      if c(k)==c(l)
          e(c(k)) = e(c(k)) + S(k, l);
      end
    end
end
e(e==0) = [];
e=mean(e);


