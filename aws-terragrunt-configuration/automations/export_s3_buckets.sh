#!/bin/bash

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install it and configure your credentials."
    exit 1
fi

# Output file
output_file="s3_buckets.yaml"

# Clear the output file if it exists
> "$output_file"

# Get list of all S3 bucket names
bucket_names=$(aws s3api list-buckets --query "Buckets[].Name" --output text)

# Write the opening of the YAML file
echo "inputs:" > "$output_file"

# Loop through each bucket
for bucket in $bucket_names; do
    # Get tags for the bucket
    tags=$(aws s3api get-bucket-tagging --bucket "$bucket" 2>/dev/null)
    
    # Write bucket information to YAML file
    echo "- bucket_name: \"$bucket\"" >> "$output_file"
    echo "  tags:" >> "$output_file"
    
    if [ -n "$tags" ]; then
        # Process tags if they exist
        echo "$tags" | jq -r '.TagSet[] | "    \(.Key): \"\(.Value)\""' >> "$output_file"
    else
        # If no tags, add a placeholder
        echo "    Name: \"$bucket\"" >> "$output_file"
    fi
    
    # Add a blank line for readability
    echo "" >> "$output_file"
done

echo "S3 bucket information has been exported to $output_file"