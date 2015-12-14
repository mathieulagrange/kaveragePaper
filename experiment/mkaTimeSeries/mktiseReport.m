function config = mktiseReport(config)
% mktiseReport REPORTING of the expCode project mkaTimeSeries
%    config = mktiseInitReport(config)
%       config : expCode configuration state

% Copyright: Mathieu Lagrange
% Date: 26-Aug-2014

if nargin==0, mkaTimeSeries('report', 'rcv',  'reportName', 'paper'); return; end

[dataSets, nbDataSets] = expFactorValues(config, 'dataSet');

% RERUN BATCH WITH LARGE NUMBER OF ITERATIONS
% RUN KKMEANS with factor one only

switch config.reportName
    case 'appendix'
               config = expExpose(config, 'l', 'mask', {0 1 2 0 0 0 2}, 'step', 1, 'highlight', -1, ...
                'obs', [1 3 4], 'caption', 'Morphology of the datasets', 'orientation', 'v', 'precision', 0, 'save', 'appendix', 'fontSize', 'small');
  
    case 'current'
        %                  config = expExpose(config, 'l', 'mask', {0 1 2 [2] [3] [1] 2 1}, 'step', 2, 'obs', [3 2],  'orientation', 'v', 'fontSize', 'small');
        %
        %                  config = expExpose(config, 'l', 'mask', {0 1 2 [9] [3] [1] 2 1}, 'step', 2, 'obs', [3 2],  'orientation', 'v', 'fontSize', 'small');
        %
        config = expExpose(config, 'l', 'mask', {0 1 2 [2 9] [3] [1] 1 1}, 'step', 2, 'obs', [3],  'orientation', 'v', 'fontSize', 'small', 'expand', 'clustering', 'number', 1);
        
    case 'simple'
        
        class2 = [7 12 13 17 20 21 25 28 29 34 42 43];
        class37 = [3 4 5 6 11 15 18 19 22 26 27 30 32 33 35 37 38];
        class8 = [1 2 8 9 10 14 16 23 24 31 36 39 40 41];
        classes = {class2 class37 class8};
        classesNames = {'2', '37', '8'};
        for k=1:length(classes)
            config = expExpose(config, 'l', 'mask', {classes{k} 1 2 [1 2 8 9] [3] [1] 2 1}, 'step', 3, 'obs', 2, 'percent', 1, 'precision', 4,  'orientation', 'vi', 'fontSize', 'small', 'orderSetting', [5 6 1 3 2 4], 'expand', 'dataSet');
        end
        config = expExpose(config, 'l', 'mask', {0 1 2 [1 2 8 9] [3] [1] 2 1}, 'step', 4, 'obs', 2, 'percent', 1, 'precision', 4);
      
    case 'database'
    case 'moved'
        load([config.reportPath '/data/movedData'], 'm');
        figure(1)
        clf
        hold on
        for k=1:length(m)
            x(k) = m{k}.size;
            y(k) = sum(m{k}.moved(:));
            plot(mean(m{k}.moved, 1)/m{k}.size, 'k');
            axis([1 30 0 1]);
        end
        xlabel('Number of iterations');
        ylabel('Normalized number of moves');
        set(gca, 'fontsize', config.displayFontSize);
        config = expExpose(config, '', 'save', ['kAveragesMoved_linePlot'], 'data', m);
        figure(2)
        clf
        scatter (x, y, 'ko', 'filled');
        set(gca, 'XScale', 'log')
        set(gca, 'YScale', 'log')
        xlabel('Number of samples');
        ylabel('Number of moves');
        set(gca, 'fontsize', config.displayFontSize);
        config = expExpose(config, '', 'save', ['kAveragesMoved_scatter'], 'data', m);
        
    case 'paper'
        class2 = [7 12 13 17 20 21 25 28 29 34 42 43];
        class37 = [3 4 5 6 11 15 18 19 22 26 27 30 32 33 35 37 38];
        class8 = [1 2 8 9 10 14 16 23 24 31 36 39 40 41];
        classes = {class2 class37 class8};
        classesNames = {'2', '37', '8'};
        %         for k=1:length(classes)
        %             config = expExpose(config, 'l', 'mask', {classes{k} 1 2 0 0 0 2}, 'step', 1, 'highlight', -1, ...
        %                 'obs', [1 2 4], 'caption', 'Morphology of the datasets', 'orientation', 'v', 'precision', 0, 'noFactor', 1);
        %             config = expExpose(config, 'l', 'mask', {classes{k} 1 2 [5 2 1] 3 1 2 1}, 'step', 2, ...
        %                 'highlight', 0, 'highlightColor', 0, 'highlightStyle', 'Better', 'obs', [3], 'percent', 0, ...
        %                 'orientation', 'vi', 'precision', 0, 'expand', 'dataSet', 'noObservation', 1, 'orderSetting', [3 2 1], 'mergeDisplay', 'h', 'save', ['methods' classesNames{k}]);
        %         end
        
        %          for k=1:length(classes)
        %             config = expExpose(config, 'l', 'mask', {classes{k} 1 2 0 0 0 2}, 'step', 1, 'highlight', -1, ...
        %                 'obs', 1, 'caption', 'Morphology of the datasets', 'orientation', 'v', 'precision', 0, 'noFactor', 1);
        %             config = expExpose(config, 'l', 'mask', {classes{k} 1 2 [2] [3 1] 1 2 1}, 'step', 2, ...
        %                 'highlight', 0, 'highlightColor', 0, 'highlightStyle', 'Better', 'obs', [3], 'percent', 0, ...
        %                 'orientation', 'vi', 'precision', 0, 'expand', 'dataSet', 'noObservation', 1, 'orderSetting', [3 2 1], 'mergeDisplay', 'h', 'save', ['methods' classesNames{k}]);
        %          end
        
        %         config = expExpose(config, 'l', 'mask', {0 0 2 [1:2] [1] [1] 2}, 'obs', [1], 'step', 1, 'precision', 0, 'highlight', -1, 'save', 'datasets');
  
              nbRuns = 4;
        norm =2;
        % timing
%                config = expExpose(config, 'l', 'mask', {0 1 norm [ 8 9] [3] [1] nbRuns 1}, 'step', 2, ...
%                 'highlight', 0, 'highlightColor', 1, 'highlightStyle', 'Better', 'obs', [4], 'percent', 0, ...
%                 'orientation', 'vi', 'precision', 0, 'expand', 'dataSet', 'total', 'h', 'fontSize', 'tiny');

        
  
        for k=1 :length(classes)
            config = expExpose(config, 'l', 'mask', {classes{k} 1 2 0 0 0 2}, 'step', 1, 'highlight', -1, ...
                'obs', [1 3 4], 'caption', 'Morphology of the datasets', 'orientation', 'v', 'precision', 0, 'noFactor', 1);
            config = expExpose(config, 'l', 'mask', {classes{k} 1 2 [8 9] [3] [1] 2 1}, 'step', 3, ...
                'highlight', 0, 'highlightColor', -1, 'highlightStyle', 'Best', 'obs', [3], 'percent', 3, ...
                'orientation', 'vi', 'precision', 1, 'expand', 'dataSet', 'noObservation', 1, 'orderSetting', [2 1], 'mergeDisplay', 'h', 'save', ['methods' classesNames{k}], 'fontSize', 'small');
  
            % object better than kkmeans
%                 config = expExpose(config, 'l', 'mask', {classes{k} 1 norm [ 8 9] [3] [1] nbRuns 1}, 'step', 2, ...
%                 'highlight', 0, 'highlightColor', 1, 'highlightStyle', 'Better', 'obs', [3], 'percent', 0, ...
%                 'orientation', 'vi', 'precision', 0, 'expand', 'dataSet', 'show', 'Best', 'total', 'H');
%   
%                  % raw better than kkmeans
%                 config = expExpose(config, 'l', 'mask', {classes{k} 1 norm [8 9] [1] [1] nbRuns 1}, 'step', 2, ...
%                 'highlight', 0, 'highlightColor', 1, 'highlightStyle', 'Better', 'obs', [3], 'percent', 0, ...
%                 'orientation', 'vi', 'precision', 0, 'expand', 'dataSet', 'show', 'Best', 'total', 'H');
%   
        
        end
  

           % object better than kkmeans
%                 config = expExpose(config, 'l', 'mask', {0 1 norm [ 8 9] [3] [1] nbRuns 1}, 'step', 2, ...
%                 'highlight', 0, 'highlightColor', 1, 'highlightStyle', 'Better', 'obs', [3], 'percent', 0, ...
%                 'orientation', 'vi', 'precision', 0, 'expand', 'dataSet', 'show', 'Best', 'total', 'H');
%   
%                  raw better than kkmeans
%                 config = expExpose(config, 'l', 'mask', {0 1 norm [8 9] [1] [1] nbRuns 1}, 'step', 2, ...
%                 'highlight', 0, 'highlightColor', 1, 'highlightStyle', 'Better', 'obs', [3], 'percent', 0, ...
%                 'orientation', 'vi', 'precision', 0, 'expand', 'dataSet', 'show', 'Best', 'total', 'H');
%   
%         system(['rsync -r ' config.reportPath(1:end-1) ' ~/Dropbox/kAverages/Paper/']);
        
    case 'check'
        class2 = [7 12 13 17 20 21 25 28 29 34 42 43];
        class37 = [3 4 5 6 11 15 18 19 22 26 27 30 32 33 35 37 38];
        class8 = [1 2 8 9 10 14 16 23 24 31 36 39 40 41];
        classes = {class2 class37 class8};
  
        for k=1 %:length(classes)
            config = expExpose(config, 't', 'mask', {classes{k} 1 2 [8 9 5] [3] [1] 2 1}, 'step', 2, ...
                'highlight', 0, 'highlightColor', 1, 'highlightStyle', 'better', 'obs', [2], 'percent', 2, ...
                'precision', 1);
        end

    otherwise
        distance = [1];
        norm = 1;
        clustering = [1 2 5];
        objective = [1 3];
        strategy = [1 3 4];
        iterations = 1;
        countType = {'better7', 'Better7', 'best', 'Best'};
        obsName = {'accuracy', '', 'nmi'};
        
        for k=1:length(countType)
            if k>2
                clustering = [1 2];
                strategy = 1;
            end
            for m=[1 3]
                config = expExpose(config, 'l', 'mask', {0 distance norm clustering objective strategy 2, iterations}, 'obs', m, 'expand', 'dataSet', 'orientation', 'v', 'numericObservations', 1, 'orientation', 'v', 'percent', 0, 'precision', 4, 'show', countType{k}, 'total', 'H', 'caption', ['+  in ' obsName{m}]);
            end
        end
end

% for dataset=1:nbDataSets
%   config = expExpose(config, 'l', 'mask', {dataset distance norm clustering objective strategy 2}, 'obs', [1 3], 'percent', [1 3], 'precision', 3);
% end

% config = expExpose(config, 'l', 'mask', {0 1 2 0 0 0 2}, 'step', 1, 'highlight', -1, 'obs', 1:3, 'number', 1, 'caption', 'Morphology of the datasets');

% for k=strategy
%     for m=objective
%
% obs = 1;
% obsName = 'accuracy';
%
% config = expExpose(config, 'l', 'mask', {0 distance norm clustering m k 2}, 'obs', obs, 'expand', 'dataSet', 'orientation', 'v', 'numericObservations', 1, 'fontSize', 'tiny', 'percent', 0, 'precision', 4, 'show', 'best', 'total', 'H', 'caption', ['+ Betters in ' obsName]);
% config = expExpose(config, 'l', 'mask', {0 distance norm clustering m k 2}, 'obs', obs, 'expand', 'dataSet', 'orientation', 'v', 'numericObservations', 1, 'fontSize', 'tiny', 'percent', 0, 'precision', 4, 'show', 'Best', 'total', 'H', 'caption', ['+ Sig better in ' obsName]);
%
% obs = 3;
% obsName = 'nmi';
%
% config = expExpose(config, 'l', 'mask', {0 distance norm clustering m k 2}, 'obs', obs, 'expand', 'dataSet', 'orientation', 'v', 'numericObservations', 1, 'fontSize', 'tiny', 'percent', 0, 'precision', 4, 'show', 'best', 'total', 'H', 'caption', ['+ Better in ' obsName]);
% config = expExpose(config, 'l', 'mask', {0 distance norm clustering m k 2}, 'obs', obs, 'expand', 'dataSet', 'orientation', 'v', 'numericObservations', 1, 'fontSize', 'tiny', 'percent', 0, 'precision', 4, 'show', 'Best', 'total', 'H', 'caption', ['+ Sig better in ' obsName]);
%     end
% end

% config = expExpose(config, 'l', 'mask', {0 distance norm clustering objective  [1 k] 2}, 'obs', obs, 'expand', 'dataSet', 'orientation', 'v', 'numericObservations', 1, 'fontSize', 'tiny', 'percent', 0, 'precision', 4, 'show', 'Best', 'total', 'h', 'caption', ['+ Sig better in ' obsName]);
%
% obs = 3;
% obsName = 'nmi';
%
% config = expExpose(config, 'l', 'mask', {0 distance norm clustering objective  [1 k] 2}, 'obs', obs, 'expand', 'dataSet', 'orientation', 'v', 'numericObservations', 1, 'fontSize', 'tiny', 'percent', 0, 'precision', 4, 'show', 'best', 'total', 'h', 'caption', ['+ Better in ' obsName]);
% config = expExpose(config, 'l', 'mask', {0 distance norm clustering objective  [1 k] 2}, 'obs', obs, 'expand', 'dataSet', 'orientation', 'v', 'numericObservations', 1, 'fontSize', 'tiny', 'percent', 0, 'precision', 4, 'show', 'Best', 'total', 'h', 'caption', ['+ Sig better in ' obsName]);

% config = expExpose(config, 'l', 'mask', {0 1 2 1:2 [1 3] [1 3] 2}, 'obs', [1], 'expand', 'dataSet', 'show', 'best', 'orientation', 'h', 'numericObservations', 1, 'fontSize', 'small', 'total', 'h');

%
% for k = 1:nbDataSets
%     config = expExpose(config, 'l', 'mask', {k 1 2 1:3 [1 3] [1 3] 2}, 'obs', [1 3 2 4], 'sort', -2);
% end