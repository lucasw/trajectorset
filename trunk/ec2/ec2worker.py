import boto
import re

import ec2start

conn = boto.connect_sqs()

startq = conn.create_queue('startq')
doneq  = conn.create_queue('doneq')

while True:
    rs = startq.get_messages()
    if len(rs) > 0:
        m = rs[0]
        msg = m.get_body()

        startq.delete_message(m)
        
        seed = -1
        # do a re match one START seed_num, and extract seed_num
        match = re.search("(START )(.*)",msg)
        seed = int(a.groups()[1])
        if (seed == None) or (seed < 0):
            continue

        # create a config.csv file with the seed in it
        cmd = "echo \"seed " + str(seed) + "\" > config.csv" 
        proc = subprocess.Popen(cmd, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        (stdout,stderr) = proc.communicate()
        i#print("CMD: " + whole_cmd)
                
        # run the traj_2d on it
        # move the output files into data[seed_num] folder
        
        m = boto.sqs.Message()
        m.set_body('DONE ' + str(seed))
        doneq.write(m)

        # finished, loop and move on to next message
