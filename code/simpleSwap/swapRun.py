import os

for m in ['kaverages', 'kkmeans']:
    for o in range(0, 10):
        for j in range(0, 10):
            command = './'+m+' -m /data/simple/testSwap_'+str(o)+'.matrix -c 5 -o /data/simple/testSwap_'+m+str(o)+'_'+str(j);
            print command
            os.system(command);

