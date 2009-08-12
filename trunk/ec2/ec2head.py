import boto
import re

conn = boto.connect_sqs()

startq = conn.create_queue('startq')
doneq  = conn.create_queue('doneq')

# to start create a bunch of start message, proportional to the size

while True:
    # 



    rs = startq.get_messages()
    if len(rs) > 0:
        m = rs[0]
        msg = m.get_body()

        startq.delete_message(m)
        
        seed = -1
        # do a re match one START seed_num, and extract seed_num
        # create a config.csv file with the seed in it
        # run the traj_2d on it
        # move the output files into data[seed_num] folder
        
        m = boto.sqs.Message()
        m.set_body('DONE ' + str(seed))
        doneq.write(m)

        # finished, loop and move on to next message
