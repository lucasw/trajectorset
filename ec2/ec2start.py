
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

#StrictHostKeyChecking=no

# ssh in and export the AWS keys

# install xvfb, need an automated 'yes' to the 'are you sure' query
# Xvfb :2 & 
#[1] 14401 
# export DISPLAY=":2" 


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




