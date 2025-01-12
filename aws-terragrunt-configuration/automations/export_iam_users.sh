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
output_file="iam_users.yaml"

# Start the YAML file
echo "users:" > $output_file

# Get all IAM users
users=$(aws iam list-users --query 'Users[*].UserName' --output json | jq -r '.[]')

# Loop through each user
for user in $users
do
    echo "  - name: \"$user\"" >> $output_file
    echo "    policy_arns:" >> $output_file

    # Get attached policies for the user
    policies=$(aws iam list-attached-user-policies --user-name "$user" --query 'AttachedPolicies[*].PolicyArn' --output json | jq -r '.[]')

    # If there are no attached policies, check for inline policies
    if [ -z "$policies" ]; then
        inline_policies=$(aws iam list-user-policies --user-name "$user" --query 'PolicyNames' --output json | jq -r '.[]')
        for policy in $inline_policies
        do
            policy_arn=$(aws iam get-user-policy --user-name "$user" --policy-name "$policy" --query 'PolicyDocument' --output json | jq -r '.Statement[].Resource')
            echo "    - \"$policy_arn\"" >> $output_file
        done
    else
        # Add each policy ARN to the YAML file
        for policy in $policies
        do
            echo "    - \"$policy\"" >> $output_file
        done
    fi

    echo "" >> $output_file
done

echo "IAM users and their policies have been exported to $output_file"