
from boto.ec2.connection import EC2Connection

# need



conn = EC2Connection()

# launch 20 or so instance of this type
#ami-0b729462
#alestic/ubuntu-9.04-jaunty-desktop-20090614.manifest.xml


# wait for most to finish


# install xvfb, need an automated 'yes' to the 'are you sure' query
# apt-get install xvfb 
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




