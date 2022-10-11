# set -ex
pushd /usr/src
[ ! -d /usr/src/caprover ] && git clone https://github.com/caprover/caprover.git --depth=1 /usr/src/caprover && cd /usr/src/caprover && npm i && npm run build
popd
echo /usr/src/caprover > /usr/src/caprover/currentdirectory
chmod 777 /usr/src/caprover/currentdirectory
pushd /usr/src
[ ! -d /usr/src/caprover-frontend ] && git clone https://github.com/caprover/caprover-frontend.git --depth=1 /usr/src/caprover && cd /usr/src/caprover-frontend && npm i && npm run build
popd


[ -z "$DEFAULT_PASSWORD" ] && DEFAULT_PASSWORD="captain42"
docker service rm $(docker service ls -q)
sleep 1s
docker secret rm captain-salt
docker build -t captain-debug -f dockerfile-captain.debug .
rm -rf /captain && mkdir /captain
chmod -R 777 /captain
docker run \
   -e "CAPTAIN_IS_DEBUG=1" \
   -e "MAIN_NODE_IP_ADDRESS=127.0.0.1" \
   -v /var/run/docker.sock:/var/run/docker.sock \
   -v /captain:/captain \
   -v /usr/src/caprover:/usr/src/app \
   -v /usr/src/caprover-frontend:/usr/src/app-frontend \
   captain-debug
sleep 2s
docker service logs captain-captain --follow
