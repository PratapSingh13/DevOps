#!/bin/bash
addingSecurityGroups()
{
    security_groups_added=$1
    instance_ids=($(aws ec2 describe-instances --filters Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].InstanceId" --output text))
    for instance in ${instance_ids[@]}
    do
        security_groups=$(aws ec2 describe-instances --filters Name=instance-state-name,Values=running --instance-id $instance --query "Reservations[*].Instances[*].SecurityGroups[*].GroupId" --output text)
        security_groups="$security_groups $security_groups_added"
        echo Adding $security_groups_added Security Group into ec2-instance $instance
        aws ec2 modify-instance-attribute --instance-id $instance --groups $security_groups
    done
}



security_groups_added=$1

addingSecurityGroups $security_groups_added
