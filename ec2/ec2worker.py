#!/usr/bin/python

# Licensed under the GNU GPL v3.0
# binarymillenium 2009

import subprocess
import boto
import re
import os
import shutil
import time
#import glob

#import ec2start

def log(msg):
    f = open("log.txt","a")
    f.write(msg + "\n")
    f.close()
    print(msg)

conn = boto.connect_sqs()

startq = conn.create_queue('startq')
doneq  = conn.create_queue('doneq')

try:
    os.mkdir("data")
except:
    pass

counter = 0
while True:

    rs = startq.get_messages()
    if len(rs) > 0:
    
        m = rs[0]
        msg = m.get_body()

        startq.delete_message(m)
        counter += 1

                # TBD need to get multiple seeds here
        seed = -1
        # do a re match one START seed_num, and extract seed_num
        seeds = msg.split(' ') 
        #seed = int(match.groups()[1])
        #if (seed == None) or (seed < 0):
        #    log("bad seed " + str(seed)) 
        #    continue
        
        log("processing seed " + str(seed)) 

        # create a config.csv file with the seed in it
        f = open("config.csv","w")
        for seed in seeds[1:]:
            f.write("seed " + seed + "\n")
        f.close()

        # run the traj_2d on it
        proc = subprocess.Popen("./traj_2d", shell=True,              
                                    stdin=subprocess.PIPE,                         
                                    stdout=subprocess.PIPE, 
                                    stderr=subprocess.PIPE)
        (stdout,stderr) = proc.communicate() 
        print("traj_2d: " + stdout)
        print("traj_2d: " + stderr)

        # move the output files into data[seed_num] folder
        try:
            os.mkdir("archive")
        except:
            pass
        shutil.move("data","archive/data" + str(counter))  
        os.mkdir("data")

        m = boto.sqs.Message()
        m.set_body(os.environ['DNS'] + ' ' + str(counter))
        doneq.write(m)
    else:
        time.sleep(1)
        # finished, loop and move on to next message
