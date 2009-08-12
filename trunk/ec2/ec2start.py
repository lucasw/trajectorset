import os
import subprocess
import boto

conn = boto.connect_ec2()

# launch 20 or so instance of this type
#ami-b15bbad8
images = conn.get_all_images('ami-b15bbad8')
# TBD error check
image = images[0]
reservation_head = image.run(1,1,security_groups=['default','http'])
inst_head = reservation_head.instances[0]

reservation_worker = image.run(1,1)
inst_workers = reservation_worker.instances

# wait for most to finish
for i in range(1, len(inst_workers)):
    while (cmp(inst_workers[i].status,"running") != 0):
        os.sleep(2)
        print('i ')


#StrictHostKeyChecking=no

# ssh in and export the AWS keys
print("exporting AWS keys")
for i in range(1, len(inst_workers)):
    cmd = "ssh -i ~/lucasw.pem root@" + inst_workers[i].dns_name + " export AWS_ACCESS_KEY_ID=" + os.environ['AWS_ACCESS_KEY_ID']  + "; export AWS_SECRET_ACCESS_KEY=" + os.environ['AWS_SECRET_ACCESS_KEY']

    proc = subprocess.Popen(cmd, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (stdout,stderr) = proc.communicate()
    print("STDOUT: " + stdout)
    print("STDERR: " + stderr)
   
    # need to detach this
    # install xvfb, need an automated 'yes' to the 'are you sure' query
    cmd = "Xvfb :2 &,# export DISPLAY=\":2\"" 
    #[1] 14401 


    # sftp exported app to all of them in 20 simultaneous sftps


# open 20 ssh sessions, run each app-
# TBD pass seed parameter to app?
# or have seed be noise() based
#  have each only cycle once (don't reset within the app)
# loop around each, make it so they don't erase existing files

# return stdout of each ssh session to this stdout
# sftp a few images of results back - maybe big grid screen?
# or just last, middle images or a few more

# after 10-20 cycles, exit
# sftp all results back

# run other app to aggregate 20 all together




