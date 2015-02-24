% function swapTest()

algo = {'kaverages', 'kkmeans'};

% for n=1:2
%     for k=1:10
%         fileName = ['/data/simple/testSwap_' algo{n} num2str(k-1) '.csv']
%         runLog = textscan(fopen(fileName), '%f,%f, %f,%f',  'HeaderLines',2);
%
%         iterations(k, n) = runLog{1}(end);
%         moved(k, n) = runLog{2}(end);
%         time(k, n) =  runLog{3}(end);
%         % log.iterationMoved = runLog{2}(1:end-1);
%         % log.iterationCriterion = runLog{3}(1:end-1);
%         % log.iterationTime = runLog{4}(1:end-1);
%     end
% end
%
% plot((time))
%
% time'


for n=1:6
    for k=1:10
        for m=1:10
            if n>2
                ext='NoSwap_';
                alg{n} = [algo{mod(n-1, 2)+1} 'No'];
            else
                ext='Swap_';
                alg{n} = [algo{mod(n-1, 2)+1}];
            end
            if n>4
              %  ext='SwapO3_';
            end
            fileName = ['/data/simple/test' ext '' algo{mod(n-1, 2)+1} num2str(k-1) '_' num2str(m-1) '.csv']
            fid = fopen(fileName);
            runLog = textscan(fid, '%f,%f, %f,%f',  'HeaderLines',2);
            fclose(fid);
            iterations(k, n, m) = runLog{1}(end);
            moved(k, n, m) = runLog{2}(end);
            time(k, n, m) =  runLog{3}(end);
        end
        % log.iterationMoved = runLog{2}(1:end-1);
        % log.iterationCriterion = runLog{3}(1:end-1);
        % log.iterationTime = runLog{4}(1:end-1);
    end
end

% time( 9, 1, 2) = time( 9, 1, 1);
vtime = squeeze(var(time, [], 3));
atime = squeeze(mean(time, 3));
csvwrite('runTime.csv', atime);
% errorbar(atime, vtime)
clf
lineStyle = {'-', '-','--', '--', ':', ':' };
marker = {'o', '*','o', '*', 'o', '*' };
for k=1:6
    semilogy(atime(:, k), 'color', 'k', 'linestyle', lineStyle{k}, 'marker', marker{k}, 'markersize', 10)
    hold on
end
hold off
% plot(squeeze(mean(time, 3)))
set(gca, 'xtick', 1:10)
set(gca, 'xticklabel', [763+161*(0:9)])
ylabel('Run time (seconds)', 'fontsize', 16)
xlabel('Matrix size (MB)', 'fontsize', 16)
set(gca, 'fontsize', 16)
axis tight
% legend(alg)
% set(gca, 'xticklabel', [10000+1000*(0:9)])
% saveas(gcf, 'simpleSwap.png')
