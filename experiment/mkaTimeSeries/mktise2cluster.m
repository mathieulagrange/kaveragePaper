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
if nargin==0, mkaTimeSeries('do', 2, 'mask', {1 1 2 [11] [1] [1] 0 1 1}); return; else store=[]; obs=[]; end

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
        case 'kkMeans'
            ticId  = tic;        
            n = size(S,1);
            clusters=init;
            %% version 1: directly implement the formula in [1]
            last = 0;
            nbIterations=0;
            SS = repmat((1:data.nbClasses)',1,n);
            while any(clusters ~= last) && nbIterations<setting.nbIterations
                E = double(bsxfun(@eq,SS,clusters));
                E = bsxfun(@rdivide,E,sum(E,2));
                T = E*S;
                Z = repmat(diag(T*E'),1,n)-2*T;
                          
                last = clusters;
                [val, clusters] = min(Z,[],1);
                nbIterations=nbIterations+1;
            end
            obs.time(k) = toc(ticId);
        case 'kAverages'
            [clusters, nbMoved] = mka(S, data.nbClasses, setting.objective, setting.strategy, init, setting.nbIterations);
            nbIterations = length(nbMoved);
            moved(k, 1:length(nbMoved)) = nbMoved;
        case 'kAveragesC++'
            [clusters, nbIterations] =  kaverages(S, init, ['s' setting.objective(1), setting.strategy], setting.nbIterations);
            clusters = double(clusters);
        case 'random'
            clusters = ceil(rand(1, data.nbSamples)*data.nbClasses);
            nbIterations =  NaN;
        case 'sc'
            Type=3;
            ticId = tic;
            % calculate degree matrix
            degs = sum(S, 2);
            D    = sparse(1:size(S, 1), 1:size(S, 2), degs);           
            % compute unnormalized Laplacian
            L = D - S;        
            % compute normalized Laplacian if needed
            switch Type
                case 2
                    % avoid dividing by zero
                    degs(degs == 0) = eps;
                    % calculate inverse of D
                    D = spdiags(1./degs, 0, size(D, 1), size(D, 2));
                    
                    % calculate normalized Laplacian
                    L = D * L;
                case 3
                    % avoid dividing by zero
                    degs(degs == 0) = eps;
                    % calculate D^(-1/2)
                    D = spdiags(1./(degs.^0.5), 0, size(D, 1), size(D, 2));
                    
                    % calculate normalized Laplacian
                    L = D * L * D;
            end           
            % compute the eigenvectors corresponding to the k smallest
            % eigenvalues
            [U, ~] = eigs(L, data.nbClasses, eps);         
            % in case of the Jordan-Weiss algorithm, we need to normalize
            % the eigenvectors row-wise
            if Type == 3
                U = bsxfun(@rdivide, U, sqrt(sum(U.^2, 2)));
            end
            U=abs(U);
            % prepare init
            options = statset();
            options.MaxIter =  setting.nbIterations;
            for l=1:data.nbClasses
                centroids(l, :) = mean(U(init==l, :));
            end
            
            clusters = kmeans(U, data.nbClasses, 'options', options, 'start', centroids, 'emptyaction', 'singleton');
            nbIterations = setting.nbIterations;
            obs.time(k) = toc(ticId);
        otherwise
            [clusters, log] = simpleClustering(setting.clustering(1:end-1), [outputFilePrefix '.matrix'],data.nbClasses, outputFilePrefix, init, strcmp(setting.objective, 'raw >/dev/null'));
            obs.time(k) = log.time;
            nbIterations = log.iterations;
    end
    intra =  energy(S, clusters);
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

