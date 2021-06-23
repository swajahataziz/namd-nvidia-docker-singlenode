# Copyright 2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

#!/bin/bash
# Load variables
BASENAME="${0##*/}"
log () {
   echo "${BASENAME} - ${1}"
 }
 AWS_BATCH_EXIT_CODE_FILE="/tmp/batch-exit-code"
 HOST_FILE_PATH="/tmp/hostfile"
# aws s3 cp $S3_INPUT $SCRATCH_DIR


touch $HOST_FILE_PATH
ip=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
  
 if [ -x "$(command -v nvidia-smi)" ] ; then
     NUM_GPUS=$(ls -l /dev/nvidia[0-9] | wc -l)
     availablecores=$NUM_GPUS
 else
     availablecores=$(nproc)
 fi

 log "instance details -> $ip:$availablecores"
 log "S3 bucket -> $S3_OUTPUT"
 log 
 echo "$ip slots=$availablecores" >> $HOST_FILE_PATH

# cd $SCRATCH_DIR
log "starting NAMD execution" 
namd2 +ppn $(nproc) +setcpuaffinity +idlepoll apoa1/apoa1.namd
sleep 2

log "copying data to scratch directory"
cp -R /usr/tmp $SCRATCH_DIR
log "zip files"
tar -czvf $JOB_DIR/batch_output_$AWS_BATCH_JOB_ID.tar.gz $SCRATCH_DIR/*
log "copy data to S3"
aws s3 cp $JOB_DIR/batch_output_$AWS_BATCH_JOB_ID.tar.gz $S3_OUTPUT/batch_output_$AWS_BATCH_JOB_ID.tar.gz

log "done! goodbye, writing exit code to 
$AWS_BATCH_EXIT_CODE_FILE and shutting down"
echo "0" > $AWS_BATCH_EXIT_CODE_FILE