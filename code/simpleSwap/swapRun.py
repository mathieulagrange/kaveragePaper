import os

for m in ['kaverages', 'kkmeans']:
    for o in range(0, 10):
        for j in range(0, 10):
            command = '~/projects/houle/dev/tools/clusteringAlgorithms/kAverages/simple/'+m+' -m /data/simple/testSwap_'+str(o)+'.matrix -c 5 -o /data/simple/testSwapO3_'+m+str(o)+'_'+str(j);
            print command
            os.system(command);

