#!/usr/bin/python

# Licensed under the GNU GPL v3.0
# binarymillenium 2009

import os
import subprocess
import re
import shutil
import time
import boto

print("connecting to sqs")
conn = boto.connect_sqs()

startq = conn.create_queue('startq')
startq.clear()

doneq  = conn.create_queue('doneq')
doneq.clear()



# create an html file 
# TBD may want to run this every cycle to change text on the page
whole_cmd="""echo " 
<html>
<meta http-equiv=\\"REFRESH\\" content=\\"2\\">
<title>Results</title>

<img src=\\"veh_time_veh_x.png\\"></img>
<img src=\\"veh_time_veh_y.png\\"></img>
<img src=\\"veh_time_veh_theta.png\\"></img>
<img src=\\"veh_x_veh_y.png\\"></img>
</html>" > /var/www/index.lighttpd.html 
"""
proc = subprocess.Popen(whole_cmd, shell=True, 
        stdin=subprocess.PIPE, 
        stdout=subprocess.PIPE, stderr=subprocess.PIPE)
(stdout,stderr) = proc.communicate()
print("make html: " + stdout)
print("make html: " + stderr)

# to start create a bunch of start message, proportional to the size
# number of seeds to have in queue
max_seed = 5000
# TBD make proportional to number of workers
step = 10
print("making " + str(max_seed/step) + " seeds messages for " + str(max_seed) + " seeds")
for seed in range(0, max_seed,step):
    m = boto.sqs.Message()
    # TBD need to put multiple seeds here
    msg = 'START'
    for offset in range (0,step):
        msg += ' ' + str(seed+offset)
    m.set_body(msg)
    startq.write(m)

try:
    os.mkdir("dataused")
except:
    pass

counter = 10000000

print("starting processing loop")
while True:
    try:
    	os.mkdir("datanew")
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
        group_num = int(match.groups()[2])
        print("DONE " + dns_name + " " +str(group_num))

        # now download the results to data
        whole_cmd = "scp -i /mnt/lucasw.pem -o StrictHostKeyChecking=no -r root@" + dns_name + ":/mnt/archive/data" +str(group_num) + " datanew/"
        proc = subprocess.Popen(whole_cmd, shell=True, 
                                stdin=subprocess.PIPE, 
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        (stdout,stderr) = proc.communicate()
        print("scp: " + stdout)
        print("scp: " + stderr)
        shutil.move("datanew/data" + str(group_num), "data")
    
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
        # TBD use plot2d_aggregat config.csv
        shutil.copy("output/veh_time_veh_x.png", "/var/www/veh_time_veh_x.png")
        shutil.copy("output/veh_time_veh_y.png", "/var/www/veh_time_veh_y.png")
        shutil.copy("output/veh_time_veh_theta.png", "/var/www/veh_time_veh_theta.png")
        shutil.copy("output/veh_x_veh_y.png", "/var/www/veh_x_veh_y.png")

        shutil.move("output/veh_time_veh_x.png", "veh_time_veh_x_" + str(counter) + ".png")
        shutil.move("output/veh_time_veh_y.png", "veh_time_veh_y_" + str(counter) + ".png")
        shutil.move("output/veh_time_veh_theta.png", "veh_time_veh_theta_" + str(counter) + ".png")
        shutil.move("output/veh_x_veh_y.png", "veh_x_veh_y_" + str(counter) + ".png")
        
        shutil.move("data", "dataused/data" + str(counter))
        counter += 1

    # finished, loop and move on to next messages after pausing
    time.sleep(2)
