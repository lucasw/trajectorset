#!/usr/bin/python

# Licensed under the GNU GPL v3.0
# binarymillenium 2009

import os
import subprocess
import boto
import time

def ssh_cmd(dns_name, cmd):
    whole_cmd = "ssh -i ~/lucasw.pem root@" + dns_name + " \"" + cmd + "\""
    
    proc = subprocess.Popen(whole_cmd, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (stdout,stderr) = proc.communicate()
    if (len(stderr) > 1):
        print("CMD: " + whole_cmd)
        print("STDOUT: " + stdout)
        print("STDERR: " + stderr)
 
def ssh_detach_cmd(dns_name,cmd):
    # can't run commands in quotes
    cmd = "nohup " + cmd + " > log.txt 2>&1 &"
    ssh_cmd(dns_name, cmd)

def scp_cmd(dns_name, files):
    whole_cmd = "scp -i ~/lucasw.pem " + files + " root@" + dns_name + ":/mnt"
    proc = subprocess.Popen(whole_cmd, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (stdout,stderr) = proc.communicate()
    if (len(stderr) > 1):
        print("CMD: " + whole_cmd)
        print("STDOUT: " + stdout)
        print("STDERR: " + stderr)
   

def setup_node(dns_name):
   
    cmd = "Xvfb :2" 
    ssh_detach_cmd(dns_name,cmd)
    
    cmd =  "echo \\\""
    cmd += "export AWS_ACCESS_KEY_ID="     + os.environ['AWS_ACCESS_KEY_ID'] + ";\n"
    cmd += "export AWS_SECRET_ACCESS_KEY=" + os.environ['AWS_SECRET_ACCESS_KEY'] + ";\n"
    cmd += "export DISPLAY=:2;\n"
    cmd += "export DNS=" + dns_name + ";\n"
    cmd += "\\\" >> ~/.bashrc"

    ssh_cmd(dns_name,cmd)


def startup(dns_name, zipname, scriptname, execname):
    scp_cmd(dns_name, zipname)
    scp_cmd(dns_name, scriptname)
    ssh_cmd(dns_name, "cd /mnt; unzip " + zipname + "; chmod a+x " + execname + "; chmod a+x " + scriptname + ";")
   

    cmd =  "echo \\\""
    cmd += "#!/bin/sh\n"
    cmd += "export AWS_ACCESS_KEY_ID="     + os.environ['AWS_ACCESS_KEY_ID'] + ";\n"
    cmd += "export AWS_SECRET_ACCESS_KEY=" + os.environ['AWS_SECRET_ACCESS_KEY'] + ";\n"
    cmd += "export DISPLAY=:2;\n"
    cmd += "export DNS=" + dns_name + ";\n"
    cmd += "cd /mnt;\n"
    cmd += "./" + scriptname + "\n"
    cmd += "\\\" >> test.sh; chmod a+x test.sh"
    
    ssh_cmd(dns_name, cmd)
    ssh_detach_cmd(dns_name,"./test.sh")
 

###########################################################
###########################################################

conn = boto.connect_ec2()

# launch 20 or so instance of this type
#ami-b15bbad8
print("finding ami")

images = conn.get_all_images('ami-b15bbad8')
# TBD error check
image = images[0]
print("starting instances")
reservation_head = image.run(1,1,security_groups=['default','http'])
inst_head = reservation_head.instances[0]

reservation_worker = image.run(3,7)

print("waiting for instances to run")
# wait for most to finish
i = 0
all_finished = False
head_finished = False
while not all_finished: 
    time.sleep(5)
    all_finished = True
    unfinished_count = 0
   
    inst_head.update()
    if (cmp(inst_head.state,"running") != 0):
        all_finished = False
        unfinished_count +=1
    else:
        head_finished = True

    for worker in reservation_worker.instances:
        worker.update()
        if (cmp(worker.state,"running") != 0):
            all_finished = False
            unfinished_count +=1
    
    i += 1
    print(str(i) + ' waiting for ' + str(unfinished_count) + ' workers')
    if (head_finished) and (i > 17):
        all_finished = True

#StrictHostKeyChecking=no

print("setting up head node")
dns_name = inst_head.dns_name
setup_node(dns_name)
# need the pem so the head node can scp files from workers
scp_cmd(dns_name, "~/lucasw.pem")
scp_cmd(dns_name, "../plot2d_aggregate/config.csv")

execname = "plot2d_aggregate"
zipname = execname + ".zip"
scriptname = "ec2head.py"
startup(dns_name, zipname, scriptname, execname)
print("http://" + dns_name)

# ssh in and export the AWS keys, start Xvfb, get them started
print("setting up worker nodes")
setup_node(inst_head.dns_name)
for worker in reservation_worker.instances:  #inst_workers:
    if (cmp(worker.state,"running") == 0):
        dns_name = worker.dns_name

        setup_node(dns_name)
   
        # scp exported app to all of them in 20 simultaneous sftps
        execname = "traj_2d"
        zipname = execname + ".zip"
        scriptname = "ec2worker.py"
        startup(dns_name, zipname, scriptname, execname)

# TBD wait for 'all done' meesg from head_node and then scp 
# final results down

