#!/bin/bash

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null
then
    echo "AWS CLI could not be found. Please install it first."
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null
then
    echo "jq could not be found. Please install it first."
    exit 1
fi

# Output file
output_file="iam_groups.yaml"

# Start the YAML file
echo "groups:" > $output_file

# Get all IAM groups
groups=$(aws iam list-groups --query 'Groups[*].GroupName' --output json | jq -r '.[]')

# Loop through each group
for group in $groups
do
    echo "  - name: \"$group\"" >> $output_file
    echo "    users:" >> $output_file

    # Get users in the group
    users=$(aws iam get-group --group-name "$group" --query 'Users[*].UserName' --output json | jq -r '.[]')

    # Add each user to the YAML file
    for user in $users
    do
        echo "    - \"$user\"" >> $output_file
    done

    echo "    group: \"$group\"" >> $output_file
    echo "" >> $output_file
done

echo "IAM groups and their users have been exported to $output_file"