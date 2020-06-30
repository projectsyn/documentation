#!/bin/bash

# Record with
# asciinema rec -t "Project Syn - Commodore Demo" -c "bash commodore.sh" ../assets/casts/commodore.cast

########################
# include the magic
########################
. demo-magic.sh -d
#PROMPT_TIMEOUT=1

# hide the evidence
clear

p '++ Welcome to Project Syn - Commodore Demo'
sleep 2

p '++ This demo assumes a running Lieutenant'

p '++ We now start a Commodore Pod with all needed configuration'

p 'kubectl -n lieutenant run commodore-shell--image=docker.io/projectsyn/commodore:latest ...'

kubectl -n lieutenant run commodore-shell \
  --image=docker.io/projectsyn/commodore:latest \
  --env=COMMODORE_API_URL="http://${LIEUTENANT_URL}/" \
  --env=COMMODORE_API_TOKEN=${LIEUTENANT_TOKEN} \
  --env=COMMODORE_GLOBAL_GIT_BASE=https://github.com/projectsyn \
  --env=SSH_PRIVATE_KEY="$(cat ${COMMODORE_SSH_PRIVATE_KEY})" \
  --env=CLUSTER_ID=${CLUSTER_ID} \
  --env=GITLAB_ENDPOINT=${GITLAB_ENDPOINT} \
  --tty --stdin --restart=Never --rm --wait \
  --image-pull-policy=Always \
  --command \
  -- /usr/local/bin/entrypoint.sh bash

exit

# As we're now in a container, this script cannot easily continue.
# Therefore this needs to be execute manually

echo "++ Now lets compile and push a catalog for $CLUSTER_ID"

ssh-keyscan ${GITLAB_ENDPOINT} >> /app/.ssh/known_hosts
commodore catalog compile $CLUSTER_ID --push
find catalog/manifests/