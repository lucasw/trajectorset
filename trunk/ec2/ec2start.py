import os
import subprocess
import boto

def ssh_cmd(dns_name, cmd):
    whole_cmd = "ssh -i ~/lucasw.pem root@" + dns_name + cmd
    
    proc = subprocess.Popen(whole_cmd, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (stdout,stderr) = proc.communicate()
    print("CMD: " + whole_cmd)
    print("STDOUT: " + stdout)
    print("STDERR: " + stderr)
 
def ssh_detach_cmd(dns_name,cmd):
    cmd = "nohup " + cmd + " > /dev/null 2>&1"
    ssh_cmd(dns_name, cmd)

def scp_cmd(dns_name, files):
    whole_cmd = "scp -i ~/lucasw.pem " + files + " root@" + dns_name + ":/mnt"
    proc = subprocess.Popen(whole_cmd, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (stdout,stderr) = proc.communicate()
    print("CMD: " + whole_cmd)
    print("STDOUT: " + stdout)
    print("STDERR: " + stderr)
   

def setup_node(dns_name):
    # nohup command > /dev/null 2>&1
    cmd = "Xvfb :2 &;" 
    ssh_nohup_cmd(dns_name,cmd)
    
    cmd = "echo \""
    cmd += "export AWS_ACCESS_KEY_ID="     + os.environ['AWS_ACCESS_KEY_ID'] + ";" 
    cmd += "export AWS_SECRET_ACCESS_KEY=" + os.environ['AWS_SECRET_ACCESS_KEY'] + ";" 
    cmd += "export DISPLAY=:2;" 
    cmd += "export DNS=" + dns_name + ";" 
    cmd += "\" >> ~/.bashrc"

    ssh_cmd(dns_name,cmd)


def startup(dns_name, zipname, scriptname, execname):
    scp_cmd(dns_name, zipname)
    scp_cmd(dns_name, scriptname)
    ssh_nohup_cmd(dns_name, "cd /mnt; unzip " + zipname + "; chmod a+x " + execname + "; chmod a+x " + scriptname + "; ./" + scriptname)
 

###########################################################

conn = boto.connect_ec2()

# launch 20 or so instance of this type
#ami-b15bbad8
images = conn.get_all_images('ami-b15bbad8')
# TBD error check
image = images[0]
reservation_head = image.run(1,1,security_groups=['default','http'])
inst_head = reservation_head.instances[0]

reservation_worker = image.run(2,2)
inst_workers = reservation_worker.instances

# wait for most to finish
for i in range(1, len(inst_workers)):
    while (cmp(inst_workers[i].status,"running") != 0):
        os.sleep(2)
        print('i ')


#StrictHostKeyChecking=no

print("setting up head node")
dns_name = inst_head.dns_name
setup_node(dns_name)
# need the pem so the head node can scp files from workers
scp_cmd(dns_name, "~/lucasw.pem")

execname = "plot2d_aggregate"
zipname = execname + ".zip"
scriptname = "ec2head.py"
startup(dns_name, zipname, scriptname, execname)

   #utility functions in here

# ssh in and export the AWS keys, start Xvfb, get them started
print("setting up worker nodes")
setup_node(inst_head.dns_name)
for i in range(1, len(inst_workers)):
    dns_name = inst_workers[i].dns_name
    setup_node(dns_name)
   
    # scp exported app to all of them in 20 simultaneous sftps
    execname = "traj_2d"
    zipname = execname + ".zip"
    scriptname = "ec2worker.py"
    startup(dns_name, zipname, scriptname, execname)

# TBD wait for 'all done' meesg from head_node and then scp 
# final results down

