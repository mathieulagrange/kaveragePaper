import os

for o in range(0, 10):
    command = './generateMatrix -n '+str(10000*(1+o/10.0))+' -c 5 -o /tmp/testSwap_'+str(o);
    print command
    os.system(command);

