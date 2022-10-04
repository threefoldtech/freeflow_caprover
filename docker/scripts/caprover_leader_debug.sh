CAPTAIN_IMAGE=${CAPTAIN_IMAGE:-rawdgastan/caprover}
CAPTAIN_IMAGE_VERSION=${CAPTAIN_IMAGE_VERSION:-captain-debug}

if [[ ! -z "${CAPROVER_ROOT_DOMAIN}" ]]; then
    echo "CapRover Root Domain: ${CAPROVER_ROOT_DOMAIN}"
    mkdir -p /captain/data
    echo "{
        \"namespace\": \"captain\",
        \"customDomain\": \"${CAPROVER_ROOT_DOMAIN}\"
    }" >/captain/data/config-captain.json
    cat /captain/data/config-captain.json
    echo "{
        \"publishedNameOnDockerHub\": \"$CAPTAIN_IMAGE\",
        \"version\": \"$CAPTAIN_IMAGE_VERSION\",
        \"skipVerifyingDomains\":\"true\"
    }" >/captain/data/config-override.json
    echo "CapRover will be available at http://captain.${CAPROVER_ROOT_DOMAIN} after installation"

fi

docker login -u rawdagastan -p Xx11221122

if ! [ $(id -u) = 0 ]; then
   echo "Must run as sudo or root"
   exit 1
fi

echo first 

pwd > currentdirectory
rm -rf /captain && mkdir /captain
chmod -R 777 /captain

echo second 

[ -z "$DEFAULT_PASSWORD" ] && DEFAULT_PASSWORD="captain42"
while ! docker run \
   -e "CAPTAIN_IS_DEBUG=1" \
   -e DEFAULT_PASSWORD="$DEFAULT_PASSWORD" \
   -v /var/run/docker.sock:/var/run/docker.sock \
   -v /captain:/captain \
   -v $(pwd):/usr/src/app $CAPTAIN_IMAGE:$CAPTAIN_IMAGE_VERSION; do
    sleep 2
done

echo "==================================="
echo " **** Installation is done! *****  "
[[ ! -z "${CAPROVER_ROOT_DOMAIN}" ]] && echo "CapRover is available at http://captain.${CAPROVER_ROOT_DOMAIN}" || echo "CapRover is available at http://{public-ip-address}:3000"
echo "Default password is: captain42"
echo "CapRover CAPTAIN IS DEBUG: ${CAPTAIN_IS_DEBUG}"
echo "==================================="
