#!/bin/bash

if ! [ $(id -u) = 0 ]; then
   echo "Must run as sudo or root"
   exit 1
fi

pushd /usr/src
curl -sL https://deb.nodesource.com/setup_16.x -o nodesource_setup.sh
bash nodesource_setup.sh
apt-get install -y nodejs
[ ! -d /usr/src/caprover ] && git clone https://github.com/caprover/caprover.git --depth=1 /usr/src/caprover 
cd /usr/src/caprover && npm i && npm run build
popd

pushd /usr/src
npm install -g yarn
[ ! -d /usr/src/caprover_frontend ] && git clone https://github.com/githubsaturn/caprover-frontend.git --depth=1 /usr/src/caprover_frontend 
cd /usr/src/caprover_frontend 
yarn install  --no-cache --frozen-lockfile --network-timeout 600000 && echo "Installation finished"
yarn run build && echo "Building finished"
mv /usr/src/caprover_frontend/build/ /usr/src/caprover/dist-frontend
popd

echo /usr/src/caprover > /usr/src/caprover/currentdirectory
chmod 777 /usr/src/caprover/currentdirectory

echo first 

docker build -t captain-debug -f scripts/dockerfile-captain.debug .
rm -rf /captain && mkdir /captain
chmod -R 777 /captain

echo second 

[ -z "$DEFAULT_PASSWORD" ] && DEFAULT_PASSWORD="captain42"
while ! docker run \
   -e "CAPTAIN_IS_DEBUG=1" \
   -e DEFAULT_PASSWORD="$DEFAULT_PASSWORD" \
   -v /var/run/docker.sock:/var/run/docker.sock \
   -v /captain:/captain \
   -v /usr/src/caprover:/usr/src/app captain-debug; do
    sleep 2
done

docker service logs captain-captain --follow

echo "==================================="
echo " **** Installation is done! *****  "
[[ ! -z "${CAPROVER_ROOT_DOMAIN}" ]] && echo "CapRover is available at http://captain.${CAPROVER_ROOT_DOMAIN}" || echo "CapRover is available at http://{public-ip-address}:3000"
echo "Default password is: captain42"
echo "CapRover CAPTAIN IS DEBUG: ${CAPTAIN_IS_DEBUG}"
echo "==================================="
