import boto
import re
import os
import shutil
#import glob

import ec2start

def log(msg):
    f = open("log.txt","a")
    f.write(msg + "\n")
    f.close()

conn = boto.connect_sqs()

startq = conn.create_queue('startq')
doneq  = conn.create_queue('doneq')

counter = 0
while True:
    rs = startq.get_messages()
    if len(rs) > 0:
        m = rs[0]
        msg = m.get_body()

        startq.delete_message(m)
        counter++

        seed = -1
        # do a re match one START seed_num, and extract seed_num
        match = re.search("(START )(.*)",msg)
        seed = int(a.groups()[1])
        if (seed == None) or (seed < 0):
            log("bad seed " + str(seed)) 
            continue
        
        log("processing seed " + str(seed)) 

        # create a config.csv file with the seed in it
        f = open("config.csv","w")
        f.write("seed " + str(seed) + "\n")
        f.close()
                
        # run the traj_2d on it
                 
        # move the output files into data[seed_num] folder
        os.mkdir("data" + str(seed))
        shutil.move("data","data" + str(seed) + "/data")  
        os.mkdir("data")

        m = boto.sqs.Message()
        m.set_body('DONE ' + str(seed))
        doneq.write(m)

        # finished, loop and move on to next message
