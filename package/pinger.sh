#!/bin/bash

if [ "${RANCHER_DEBUG}" == "true" ]; then
    set -x
fi

rc=0
cid=$(docker ps|grep ipsec-router |gawk '{print $1}')
hname=$(hostname)
hip=$(hostname -i)

declare -A HOSTMAP
IFS='
'



while read hst; do
  uuid=$(docker exec $cid curl -s http://rancher-metadata.rancher.internal/2015-12-19/hosts/$hst/uuid)
  HOSTMAP["$uuid"]=$hst
done << EOF
$(docker exec $cid curl -s http://rancher-metadata.rancher.internal/2015-12-19/hosts|gawk -F "=" '{print $2}')
EOF

for testcid in `docker ps|grep -v agent|grep -v IMAGE|grep -v ipsec|grep -v metadata|grep -v network|grep -v healthcheck|grep -v logspout|grep -v cleanup|grep -v haproxy|awk '{print $1}'`; do
  while read cname; do
     cstat=$(docker exec $cid curl -s http://rancher-metadata.rancher.internal/2015-12-19/containers/$cname/state)
     checkstat='running'
     if test "$cstat" = "$checkstat"
     then
        cip=$(docker exec $cid curl -s http://rancher-metadata.rancher.internal/2015-12-19/containers/$cname/primary_ip)
        uuid=$(docker exec $cid curl -s http://rancher-metadata.rancher.internal/2015-12-19/containers/$cname/host_uuid)
        hst=${HOSTMAP["$uuid"]}
        srccontip=$(docker exec $testcid curl -s  http://rancher-metadata.rancher.internal/2015-12-19/self/container/primary_ip)
        if test "$cip" = ""
        then
           echo {cip=$cip}
           cip=$(docker exec $cid curl -s http://rancher-metadata.rancher.internal/2015-12-19/containers/$cname/primary_ip)
           echo {cip=$cip}
        fi

        docker exec $testcid ping -c 1 -W 10 $cip >/dev/null; if [ $? -ne 0 ] ; then rc=1; echo "       >>> $hname -> $hst <<<                   Error pingigng $cname/$cip [$hst] from $testcid/$srccontip [$hname/$hip]" >&2 ; fi
     fi
  done << EOF
$(docker exec $cid curl -s http://rancher-metadata.rancher.internal/2015-12-19/containers|grep -v Agent|grep -v ipsec|grep -v metadata|grep -v network|grep -v healthcheck|grep -v logspout|grep -v cleanup|gawk -F "=" '{print $2}')
EOF

done

exit $rc

