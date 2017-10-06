function [config, store, obs] = mktise2cluster(config, setting, data)
% mktise2cluster CLUSTER step of the expCode project mkaTimeSeries
%    [config, store, obs] = mktise2cluster(config, setting, data)
%      - config : expCode configuration state
%      - setting   : set of factors to be evaluated
%      - data   : processing data stored during the previous step
%      -- store  : processing data to be saved for the other steps
%      -- obs    : observations to be saved for analysis

% Copyright: Mathieu Lagrange
% Date: 26-Aug-2014

% Set behavior for debug mode
if nargin==0, mkaTimeSeries('do', 2, 'mask', {[1], 1, 2, [1], [3], [1], 1, 1}); return; else store=[]; obs=[]; end

expRandomSeed();
% should generate the init now

data.distance(data.distance==Inf) = NaN;
data.distance(isnan(data.distance)) = max(data.distance(:));

if isvector(data.distance)
    S = squareform(data.distance)-min(data.distance);
    S = S/max(S(:));
    S = 1-S;
else
    S = data.distance;
    S = S-min(S(:));
    S = S/max(S(:));
end



if strfind(setting.clustering, 'sC')
    outputFilePrefix = expSave(config, [], 'data') ;
    outputFilePrefix = outputFilePrefix(1:end-4);
    simpleWriteMatrix(S, [outputFilePrefix '.matrix']);
end

for k=1:setting.nbRuns
    init = ceil(rand(1, data.nbSamples)*data.nbClasses);
    switch setting.clustering
        case 'kMeans'
            samples = load([config.inputPath setting.dataSet filesep setting.dataSet '_TRAIN']);
            samples = [samples; load([config.inputPath setting.dataSet filesep setting.dataSet '_TEST'])];
            class = samples(:, 1);
            samples(:, 1) = [];
            
            if setting.normalizeData == 1
                samples=bsxfun(@minus,samples,mean(samples,2));
                samples=bsxfun(@rdivide,samples,std(samples,[],2));
            end
            options = statset();
            options.MaxIter =  setting.nbIterations;
            for l=1:data.nbClasses
                centroids(l, :) = mean(samples(init==l, :));
            end
            nbIterations = 0;
            warning off all
            try
                clusters = kmeans(samples, data.nbClasses, 'options', options, 'start', centroids, 'emptyaction', 'singleton');
            catch
                fprintf(2, 'Matlab kmeans did not converged.\n');
                clusters = init;
            end
            warning on all
        case 'kkMeans1'
            [clusters, intra, nbIterations] = knkmeans(S, init, setting.nbIterations, 1);
        case 'kkMeans'
            [clusters, intra, nbIterations] = knkmeans(S, init, setting.nbIterations);
            
        case 'kAverages'
            [clusters, nbMoved] = mka(S, data.nbClasses, setting.objective, setting.strategy, init, setting.nbIterations);
            nbIterations = length(nbMoved);
            moved(k, 1:length(nbMoved)) = nbMoved;
            intra =  energy(S, clusters);
        case 'kAveragesC++'
            [clusters, nbIterations] =  kaverages(S, init, ['s' setting.objective(1), setting.strategy], setting.nbIterations);
        case 'random'
            clusters = ceil(rand(1, data.nbSamples)*data.nbClasses);
            nbIterations =  NaN;
        case 'cluto'
            matrixFileName = ['/tmp/' config.experimentName '_' setting.infoShortString '.csv'];
            dlmwrite(matrixFileName, data.nbSamples, 'delimiter', ' ');
            dlmwrite(matrixFileName, S, 'delimiter', ' ', '-append');
            
            system(['~/versioned/paperKaverages15/code/cluto-2.1.1/Linux/scluster -clmethod=' setting.cluto ' ' matrixFileName ' ' num2str(data.nbClasses)]);
            clusters = csvread([matrixFileName '.clustering.' num2str(data.nbClasses)]);
            intra = 0;
            nbIterations = 0;
        case 'sc'
            [C, L, U] = SpectralClustering(S, data.nbClasses, 3);
            % prepare init
            options = statset();
            options.MaxIter =  setting.nbIterations;
            for l=1:data.nbClasses
                centroids(l, :) = mean(U(init==l, :));
            end
            
            clusters = kmeans(U, data.nbClasses, 'options', options, 'start', centroids, 'emptyaction', 'singleton');
         intra =  energy(S, clusters);
         nbIterations = setting.nbIterations;
        otherwise
            [clusters, log] = simpleClustering(setting.clustering(1:end-1), [outputFilePrefix '.matrix'],data.nbClasses, outputFilePrefix, init, strcmp(setting.objective, 'raw >/dev/null'));
            obs.time(k) = log.time;
            nbIterations = log.iterations;
             intra =  energy(S, clusters);
    end
    clusterSet(k, :) = clusters;
    
    metrics = clusteringMetrics(clusters, data.class);
    obs.nmi(k) = metrics.nmi;
    obs.energy(k) = sum(intra);
    obs.accuracy(k) = metrics.accuracy;
    obs.iterations(k) = nbIterations;
end


store.clusters = clusterSet;
store.class = data.class;


if isfield(config, 'plot')
    switch setting.clustering
        case 'kkMeans'
            clf
            subplot(311)
            plot(conv(:, 1))
            title('first term');
            subplot(312)
            plot(conv(:, 2))
            title('second term');
            subplot(313)
            plot(conv(:, 3))
            title('total energy');
            axis tight
            config = expExpose(config, '', 'save', ['kkMeansConvergence' num2str(setting.infoId(1))]);
            
        case 'kAverages'
            type = 1;
            switch type
                case 1
                    if setting.id==1
                        m={};
                        save([config.reportPath '/data/movedData'], 'm');
                    else
                        load([config.reportPath '/data/movedData'], 'm');
                    end
                    m{end+1}.size = size(S, 1);
                    m{end}.moved = moved;
                    save([config.reportPath '/data/movedData'], 'm');
                case 2
                    subplot(4, 1, mod(setting.id-1, 4)+1)
                    plot(mean(moved, 1))
                    title([setting.objective ' '  setting.strategy])
                    if ~mod(setting.id, 4)
                        config = expExpose(config, '', 'save', ['kAveragesMoved_' setting.dataSet]);
                        title(setting.dataSet)
                        clf
                    end
                case 3
                    config.plotData.data(mod(setting.id-1, 4)+1, 1:size(moved, 2)) = mean(moved, 1);
                    config.plotData.legend{mod(setting.id-1, 4)+1} = [setting.objective ' '  setting.strategy];
                    if ~mod(setting.id, 4)
                        clf
                        config.plotData.data(config.plotData.data==0) = NaN;
                        plot(config.plotData.data')
                        legend(config.plotData.legend)
                        title(setting.dataSet)
                        
                        config = expExpose(config, '', 'save', ['kAveragesMoved_' setting.dataSet]);
                        config.plotData = [];
                    end
            end
    end
end

