while ! docker swarm join --token $SWMTKN $LEADER_PUBLIC_IP:2377; do
    sleep 2
done