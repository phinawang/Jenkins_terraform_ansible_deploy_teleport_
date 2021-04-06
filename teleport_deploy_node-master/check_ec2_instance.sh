#!/bin/bash


PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

TELEPORT_APTH='/opt/teleport_deploy_node'
WRITE_FILE="${TELEPORT_APTH}/out.txt"
WRITE_IPS="${TELEPORT_APTH}/ip.txt"
PROVISION_STATE=`cat "${TELEPORT_APTH}/provision/terraform.tfstate"`
echo '-----get terraform apply state------- '
echo "$PROVISION_STATE"| jq '.outputs.teleport_node_instance_id.value[]' > $WRITE_FILE
echo "$PROVISION_STATE"| jq '.outputs.teleport_node_private_ip.value[]' > $WRITE_IPS
#echo $PROVISION_OUTPUT 
#echo $PROVISION_OUTPUT > /opt/teleport_deploy_node/out.txt

echo '[PROCESS]-----parsing private ip address-------------- '
#jq -c '.[]' $PRO
#    echo $i
#done
cat $WRITE_FILE

echo '[PROCESS]-----run AWS CLI to check deploy status------- '
while read p
do
  #INSTANCE_ID="${p}"
  #INSTANCE_ID="${p}"| sed 's/\"//g'
  INSTANCE_ID="${p%\"}"
  INSTANCE_ID="${INSTANCE_ID#\"}"
  #echo $INSTANCE_ID
  printf "[PROCESS]Get status from instance -- ${INSTANCE_ID}\n"
  INSTANCE_STATE="default"
  i=0
  while [[ $i<60 ]]
  do
    # Get instance status
    INSTANCE_STATE=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --output text --query 'Reservations[*].Instances[*].State.Name')
    echo "${INSTANCE_STATE}"
    if [ "${INSTANCE_STATE}" = "running" ] 
    then
     	break
    fi
    sleep 10
    i=i+1
  done
  echo "${INSTANCE_ID} ALREADY RUNNING"
done < $WRITE_FILE

#| sed 's/"//g'



