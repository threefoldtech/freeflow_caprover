CAPTAIN_IMAGE=abom/caprover-captain
CAPTAIN_IMAGE_VERSION=latest

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

while ! docker run -p 80:80 -p 443:443 -p 3000:3000 -v /var/run/docker.sock:/var/run/docker.sock -v /captain:/captain $CAPTAIN_IMAGE:$CAPTAIN_IMAGE_VERSION; do
    sleep 2
done

echo "==================================="
echo " **** Installation is done! *****  "
[[ ! -z "${CAPROVER_ROOT_DOMAIN}" ]] && echo "CapRover is available at http://captain.${CAPROVER_ROOT_DOMAIN}" || echo "CapRover is available at http://{public-ip-address}:3000"
echo "Default password is: captain42"
echo "==================================="
