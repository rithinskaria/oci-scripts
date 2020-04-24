#!/bin/bash

######################################## Compartment ####################################################
oci iam compartment list --query "data[].{Name:\"display-name\", State:\"lifecycle-state\", Compartment_OCID:\"compartment-id\"}" --output table

read -p "Select compartment OCID" cid

################################# VCN ######################################################################
read -p "Do you want to create a new VCN or use an exisiting one? (Y/N):" vcn_yn

#echo $vcn_yn

if [[ $vcn_yn = "Y" ]] || [[ $vcn_yn = "y" ]]

then

read -p "Enter name for your VCN:" vcn_name
read -p "Enter the CIDR value": vcn_cidr
read -p "Enter DNS label:" vcn_dns

#Creating VCN
echo "Creating VCN for the instance"

vcn_id=$(oci network vcn create --compartment-id $cid --cidr-block $vcn_cidr --display-name $vcn_name --dns-label $vcn_dns | grep "\"id\"" |cut -d "\"" -f4) || exit



sec_id=$(oci network vcn get --vcn-id $vcn_id | grep default-security-list-id | cut -d "\"" -f4)

if [ $vcn_id -eq $null ]; then

echo "VCN not created, check the error above and fix it!"
exit

else

echo "VCN created!, creating subnet"
echo "VCN id:"$vcn_id

fi

elif [[ $vcn_yn = "N" ]] || [[ $vcn_yn = "n" ]]

then

echo "Fetching available VCNs"

oci network vcn list --compartment-id $cid --query "data[].{Name:\"display-name\",OCID:id,CIDR:\"cidr-block\"}" --output table

read -p "Copy the OCID of the VCN and input:" vcn_id

sec_id=$(oci network vcn get --vcn-id $vcn_id | grep default-security-list-id | cut -d "\"" -f4)

else

echo "Invalid choice, exiting" 
exit

fi

################################################################################################################################################


############################################################ Subnet ##################################################################################
#Creating subnet

read -p "Do you want to create a new subnet or use an exisiting one? (Y/N):" vcn_sub_yn

if [[ $vcn_sub_yn = "Y" ]] || [[ $vcn_sub_yn = "y" ]]; then

read -p "Enter name for subnet:" $vcn_sub_name

vcn_sub_id=$(oci network subnet create --cidr-block 192.168.1.0/24 --compartment-id $cid --vcn-id $vcn_id --display-name $vcn_sub_name --security list '["'"$sec_id"'"]')

if [ $vcn_sub_id -eq $null ]; then

echo "Subnet not created, check the error above and fix it!"

exit

else

echo "Subnet created, creating gateway"
echo "Subnet id:"$vcn_sub_id

fi

elif [[ $vcn_sub_yn = "N" ]] || [[ $vcn_sub_yn = "n" ]]; then

echo "Fetching available subnets in the VCN"

oci network subnet list --vcn-id $vcn_id --compartment-id $cid --query "data[].{Name:\"display-name\", OCID:id, CIDR:\"cidr-block\"}" --output table

read -p "Select subnet if available:" vcn_sub_id

else

echo "Invalid choice, retry"

exit

fi

##################################################################################################################################################






