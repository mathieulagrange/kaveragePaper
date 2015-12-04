function [config, store, obs] = mktise1similarity(config, setting, data)            
% mktise1similarity SIMILARITY step of the expCode project mkaTimeSeries            
%    [config, store, obs] = mktise1similarity(config, setting, data)                
%      - config : expCode configuration state                                       
%      - setting   : set of factors to be evaluated                                 
%      - data   : processing data stored during the previous step                   
%      -- store  : processing data to be saved for the other steps                  
%      -- obs    : observations to be saved for analysis                            
                                                                                    
% Copyright: Mathieu Lagrange                                                       
% Date: 26-Aug-2014                                                                 
                                                                                    
% Set behavior for debug mode                                                       
if nargin==0, mkaTimeSeries('do', 1, 'mask', {0 1 2 0 0 0 2}, 'store', 0); return; else store=[]; obs=[]; end


samples = load([config.inputPath setting.dataSet filesep setting.dataSet '_TRAIN']);
samples = [samples; load([config.inputPath setting.dataSet filesep setting.dataSet '_TEST'])];
class = samples(:, 1);
samples(:, 1) = [];
% normalize
if setting.normalizeData == 1
    samples=bsxfun(@minus,samples,mean(samples));
    samples=bsxfun(@rdivide,samples,std(samples,[]));
end

if config.dummy
    samples = samples(1:config.dummy, :);
    class = class(1:config.dummy);
end
nbSamples = size(samples, 1);

% record display statistics of databases
obs.id = setting.id;
obs.nbClasses = length(unique(class));
obs.nbSamples = nbSamples;
obs.nbSamplesPerClass = hist(class, unique(class));
obs.length = size(samples, 2);

% compute similarity
if config.store
d = zeros(1, nbSamples*(nbSamples-1)/2);
switch setting.distance
    case 'dtw'      
        n=1;
        for k=1:nbSamples
            for m=k+1:nbSamples
                d(n) = dtw_c(samples(k, :), samples(m, :), 10);
                n = n+1;
            end
        end
    case 'euclidean'
        d = pdist(samples);
    case 'linear'
        d = samples*samples';
end
store.distance = d;
store.class = class;
store.nbClasses = length(unique(store.class));
store.nbSamples = nbSamples;
end
