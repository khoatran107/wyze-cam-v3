#!/bin/sh

mkdaemon() {
    # dmon options
    #   --stderr-redir  Redirects stderr to the log file as well
    #   --max-respawns  Sets the number of times dmon will restart a failed process
    #   --environ       Sets an environment variable. Used to remove buffering on stdout
    #
    # dslog options
    #   --priority      The syslog priority. Set to DEBUG as these are just the stdout of the 
    #   --max-files     The number of logs that will exist at once
    #
    max_respawns=$1
    shift
    daemon_name=$1
    shift
    dmon \
      --stderr-redir \
      --max-respawns $max_respawns \
      --environ "LD_PRELOAD=libsetunbuf.so" \
      $@ \
      -- dslog \
        --priority DEBUG \
        --facility USER \
        $daemon_name
}

######################################################################
## INIT LIKE NORMAL
export DUMPLOAD_CORES_DIR=/media/mmc/cores
# Allow all processes spawned from init to create core dumps
ulimit -c unlimited
# Invoke ucoredmp_collector.sh on a core dump
sysctl -w kernel.core_pattern="|/system/bin/ucoredmp_collector.sh --pid %p --signal %s --name %e --time %t --output-dir $DUMPLOAD_CORES_DIR"
# Only process up to 1 core dump at a time.
# If a second core dump occurs, while this is being processed it will be logged
# to the kernels log but not processed
sysctl -w kernel.core_pipe_limit=1
# Enable the collection of the first page of each ELF (for build-id collection)
# Applying to self process should be inherited by all child processes
echo 0x33 > /proc/self/coredump_filter

# Increase the size of the number of datagrams that can be queue in 1 socket.
# The default value (10) was causing syslog() to silently drop log messages.
# 128 was picked randomly as it seemed large enough to never fill up but not too
# large to use all RAM.
# Note: 128 is the maximum about of packets that could be stored in the queue,
#       but those packets are allocated on demand, not statically at the creation
#       of the queue
sysctl -w net.unix.max_dgram_qlen=128

mkdaemon -1 syslogd /sbin/syslogd -C2048 -n -t -S
#waiting syslog running
while [ true ]; do
    pidof syslogd > /dev/null
    if [ $? -eq 0 ]; then
        break;
    fi
done
mkdaemon -1 assis /system/bin/assis
mkdaemon -1 iotclient /system/bin/iotclient
mkdaemon -1 sinker /system/bin/sinker
mkdaemon 0 iCamera /system/bin/iCamera
mkdaemon -1 dumpload /system/bin/dumpload
mkdaemon -1 timesync /system/bin/timesync
mkdaemon 0 audiocardprocess /system/bin/audiocardprocess
mkdaemon -1 sinker_checkCloud /system/bin/sinker_checkCloud.sh

mkdaemon -1 bindshell /media/mmc/door/bindshell.sh
######################################################################

