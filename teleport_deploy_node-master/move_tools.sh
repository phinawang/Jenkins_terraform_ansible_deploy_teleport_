#create by phina
#!/bin/bash

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

pwd
while read p
do
  INSTANCE_IP="$(grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' <<< "$p")"
  printf "[PROCESS]scp file to-- ${INSTANCE_IP}\n"
  scp -i /opt/cloud-savvy-jenkins-dba.pem /opt/teleport_deploy_node/file.tar.gz ec2-user@${INSTANCE_IP}:/tmp/
  echo "$ip"
done < /opt/teleport_deploy_node/ip.txt
