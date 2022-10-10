
if ! [ $(id -u) = 0 ]; then
   echo "Must run as sudo or root"
   exit 1
fi

echo first 

docker build -t captain-debug -f /scripts/dockerfile-captain.debug .
rm -rf /captain && mkdir /captain
chmod -R 777 /captain

echo second 

[ -z "$DEFAULT_PASSWORD" ] && DEFAULT_PASSWORD="captain42"
while ! docker run \
   -e "CAPTAIN_IS_DEBUG=1" \
   -e DEFAULT_PASSWORD="$DEFAULT_PASSWORD" \
   -v /var/run/docker.sock:/var/run/docker.sock \
   -v /captain:/captain \
   -v /usr/src/app/caprover:/usr/src/app captain-debug; do
    sleep 2
done

echo "==================================="
echo " **** Installation is done! *****  "
[[ ! -z "${CAPROVER_ROOT_DOMAIN}" ]] && echo "CapRover is available at http://captain.${CAPROVER_ROOT_DOMAIN}" || echo "CapRover is available at http://{public-ip-address}:3000"
echo "Default password is: captain42"
echo "CapRover CAPTAIN IS DEBUG: ${CAPTAIN_IS_DEBUG}"
echo "==================================="
