#!/bin/bash

if [[ $SWM_NODE_MODE == "leader" ]]; then
    source /scripts/caprover_leader.sh
fi
