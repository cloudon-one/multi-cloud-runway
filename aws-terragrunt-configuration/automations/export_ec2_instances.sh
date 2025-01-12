#!/bin/bash

# Set the AWS region
AWS_REGION="eu-west-1"

# Enable debug mode
set -x

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Please install it and try again."
    exit 1
fi

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install it and configure it with appropriate credentials."
    exit 1
fi

# Fetch EC2 instance information for eu-west-1 region
instances=$(aws ec2 describe-instances --region $AWS_REGION --query 'Reservations[*].Instances[*]' --output json)

# Check if the instances variable is empty or null
if [ -z "$instances" ] || [ "$instances" == "null" ]; then
    echo "No instances found or error in AWS CLI output."
    exit 1
fi

# Print the raw JSON for debugging
echo "Raw JSON output:"
echo "$instances"

# Start YAML file
echo "ec2_instances:" > ec2_instances.yaml

# Process each instance
echo "$instances" | jq -c '.[][]' | while read -r instance; do
    if [ -z "$instance" ] || [ "$instance" == "null" ]; then
        echo "Empty or null instance data, skipping."
        continue
    fi

    name=$(echo "$instance" | jq -r '.Tags[] | select(.Key=="Name") | .Value // "N/A"')
    ami=$(echo "$instance" | jq -r '.ImageId // "N/A"')
    az=$(echo "$instance" | jq -r '.Placement.AvailabilityZone // "N/A"')
    private_ip=$(echo "$instance" | jq -r '.PrivateIpAddress // "N/A"')
    public_ip=$(echo "$instance" | jq -r '.PublicIpAddress // "N/A"')
    subnet_id=$(echo "$instance" | jq -r '.SubnetId // "N/A"')
    instance_type=$(echo "$instance" | jq -r '.InstanceType // "N/A"')
    ebs_volumes=$(echo "$instance" | jq -r '.BlockDeviceMappings[].Ebs.VolumeId // "N/A"')

    # Write instance information to YAML file
    cat << EOF >> ec2_instances.yaml
  - name: "$name"
    ami: "$ami"
    availability_zone: "$az"
    private_ip: "$private_ip"
    associate_public_ip_address: "$public_ip"
    subnet_id: "$subnet_id"
    instance_type: "$instance_type"
    ebs_block_device:
EOF

    # Add EBS volumes
    if [ "$ebs_volumes" != "N/A" ]; then
        echo "$ebs_volumes" | while read -r volume; do
            echo "      - \"$volume\"" >> ec2_instances.yaml
        done
    else
        echo "      - \"N/A\"" >> ec2_instances.yaml
    fi

    # Add tags
    echo "    tags:" >> ec2_instances.yaml
    tags=$(echo "$instance" | jq -r '.Tags[]? // empty')
    if [ -n "$tags" ]; then
        echo "$tags" | while read -r tag; do
            key=$(echo "$tag" | jq -r '.Key // "N/A"')
            value=$(echo "$tag" | jq -r '.Value // "N/A"')
            echo "      $key: \"$value\"" >> ec2_instances.yaml
        done
    else
        echo "      N/A: \"N/A\"" >> ec2_instances.yaml
    fi

    echo "" >> ec2_instances.yaml
done

echo "EC2 instance information for region $AWS_REGION has been saved to ec2_instances.yaml"

# Disable debug mode
set +x