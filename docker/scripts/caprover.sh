#!/bin/bash

if [[ $SWM_NODE_MODE == "leader" ]]; then
    source /scripts/caprover_leader.sh
elif [[ $SWM_NODE_MODE == "worker" ]]; then
    source /scripts/caprover_worker.sh
else
    echo "you have to set the SWM_NODE_MODE env var to worker or leader"
fi
