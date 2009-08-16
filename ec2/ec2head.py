#!/usr/bin/python

# Licensed under the GNU GPL v3.0
# binarymillenium 2009

import os
import subprocess
import re
import shutil
import time
import boto

conn = boto.connect_sqs()

startq = conn.create_queue('startq')
startq.clear()

doneq  = conn.create_queue('doneq')
doneq.clear()


# to start create a bunch of start message, proportional to the size

# create an html file 
# TBD may want to run this every cycle to change text on the page
whole_cmd="""echo " 
<html>
<meta http-equiv=\\"REFRESH\\" content=\\"2\\">
<title>Results</title>

<img src=\\"output.png\\"></img>
</html>" > /var/www/index.lighttpd.html 
"""
proc = subprocess.Popen(whole_cmd, shell=True, 
        stdin=subprocess.PIPE, 
        stdout=subprocess.PIPE, stderr=subprocess.PIPE)
(stdout,stderr) = proc.communicate()
print("make html: " + stdout)
print("make html: " + stderr)

max_seed = 1000
# number of seeds to have in queue
# TBD make proportional to number of workers
#num_seeds = 10



for seed in range (0, max_seed):
    m = boto.sqs.Message()
    m.set_body('START ' + str(seed))
    startq.write(m)

try:
    os.mkdir("dataused")
except:
    pass

counter = 10000000

while True:
    try:
    	os.mkdir("data")
    except OSError:
        pass
    rs = doneq.get_messages()
    # TBD may not want to process all the messages, if it will take 
    # longer than a few seconds- would rather do only a few
    # and more quickly update
    for m in rs:
        msg = m.get_body()
        doneq.delete_message(m)
        
        # extract the dnsname and the seed number from the message
        match = re.search("(.*)( )(\w+)", msg)
        dns_name = match.groups()[0]
        seed = int(match.groups()[2])
        print("DONE " + dns_name + " " +str(seed))

        # now download the results to data
        whole_cmd = "scp -i /mnt/lucasw.pem -o StrictHostKeyChecking=no -r root@" + dns_name + ":/mnt/archive/data" + str(seed) + " data/"
        proc = subprocess.Popen(whole_cmd, shell=True, 
                                stdin=subprocess.PIPE, 
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        (stdout,stderr) = proc.communicate()
        print("scp: " + stdout)
        print("scp: " + stderr)

    # if there are few new data files
    if len(rs) > 0:
        # run plot2d_aggregate
        proc = subprocess.Popen("./plot2d_aggregate", shell=True, 
                                stdin=subprocess.PIPE, 
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        (stdout,stderr) = proc.communicate()
        print("plot2d: " + stdout)
        print("plot2d: " + stderr)

        # copy results to /var/www
        shutil.copy("output.png", "/var/www/output.png")
        shutil.move("output.png", "output" + str(counter) + ".png")
        shutil.move("data", "dataused/data" + str(counter))
        counter += 1

    # finished, loop and move on to next messages after pausing
    time.sleep(1)
