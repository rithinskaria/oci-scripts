#!/bin/bash
cid=<<YOUR COMPARTMENT ID>>

instance_number=$(oci compute instance list -c $cid --query "data[].id" | grep -v -e "\[" -e "\]" | wc -l)

echo "Number of VMs:"$instance_number

array_id=$(oci compute instance list -c $cid --query "data[].id" | grep -v -e "\[" -e "\]" | sed 's/\"//g' | sed 's/[[:blank:]]//g')

cat << EOF

+---------------+------------+-----------------+-----------+-------------------------------------------------------------------------------------------+
| VM Name          | Private IP           | Public IP          | Lifecycle State               |                         Subnet                        |
+---------------+------------+-----------------+-----------+-------------------------------------------------------------------------------------------+
EOF

for (( i=1; i<=$instance_number; i++))

do

instance_id=$( echo $array_id | cut -d "," -f$i)
oci compute instance list-vnics --instance-id $instance_id --query "data[].{Name:\"display-name\", Private_IP:\"private-ip\", Public_IP:\"public-ip\", State:\"lifecycle-state\", Subnet_id:\"subnet-id\"}" --output table | grep -v "Name" 

done
