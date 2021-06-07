#!/bin/bash
addingSecurityGroups()
{
    security_groups_added=$1
    instance_ids=($(aws ec2 describe-instances \
    --filters Name=instance-state-name,Values=running \
    --query "Reservations[*].Instances[*].InstanceId" \
    --output text))
    for instance in ${instance_ids[@]}
    do
        security_groups=$(aws ec2 describe-instances --filters Name=instance-state-name,Values=running --instance-id $instance --query "Reservations[*].Instances[*].SecurityGroups[*].GroupId" --output text)
        security_groups="$security_groups $security_groups_added"
        echo Adding $security_groups_added Security Group into ec2-instance $instance
        aws ec2 modify-instance-attribute --instance-id $instance --groups $security_groups
    done
}
anywhereIngressSecurityGroup()
{
    non_compliant_security_groups=($(aws ec2 describe-security-groups --filters Name=ip-permission.cidr,Values='0.0.0.0/0' --query "SecurityGroups[*].{Name:GroupName,ID:GroupId}" --output text))
    instance_ids=($(aws ec2 describe-instances  --query "Reservations[*].Instances[*].InstanceId" --output text))
    total_instances_with_non_compliant_security_group=0
    for instance_id in ${instance_ids[@]}
    do
        flag=0
        security_groups=($(aws ec2 describe-instances --instance-id $instance_id --query "Reservations[*].Instances[*].SecurityGroups[*].GroupId" --output text))
        used_non_compliant_security_groups=""
        for security_group_id in ${security_groups[@]}
        do
            if [[ "${non_compliant_security_groups[@]}" =~  "${security_group_id}" ]]
            then
                flag=1
                used_non_compliant_security_groups="$security_group_id, $used_non_compliant_security_groups"
            fi
        done
        used_non_compliant_security_groups=$(echo $used_non_compliant_security_groups | rev | sed "s/,//" | rev)
        if [[ $flag == 1 ]]
        then
            let total_instances_with_non_compliant_security_group=$total_instances_with_non_compliant_security_group+1
            echo "$instance_id : $used_non_compliant_security_groups"
        fi
    done
    echo "Total Instances with Non-Compliant Security Group: $total_instances_with_non_compliant_security_group"
}
security_groups_added=$1
addingSecurityGroups $security_groups_added
anywhereIngressSecurityGroup
