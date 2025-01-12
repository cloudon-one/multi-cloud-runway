#!/bin/bash

# Set the default region
export AWS_DEFAULT_REGION="eu-west-1"

# Set the output file name
output_file="dynamodb_tables.yaml"

# Function to get autoscaling settings for a table
get_autoscaling_settings() {
    local table_name=$1
    local dimension=$2
    
    aws application-autoscaling describe-scaling-policies \
        --service-namespace dynamodb \
        --resource-id "table/${table_name}" \
        --query "ScalingPolicies[?contains(ResourceId, '${dimension}')]" \
        --output json
}

# Clear the output file
> "$output_file"

# Get all DynamoDB table names
tables=$(aws dynamodb list-tables --query "TableNames[]" --output text)

# Iterate through each table
for table in $tables; do
    echo "Processing table: $table"
    
    # Get table details
    table_info=$(aws dynamodb describe-table --table-name "$table" --query "Table")
    
    # Extract billing mode
    billing_mode=$(echo "$table_info" | jq -r '.BillingModeSummary.BillingMode // "PROVISIONED"')
    
    # Extract read and write capacity
    read_capacity=$(echo "$table_info" | jq -r '.ProvisionedThroughput.ReadCapacityUnits // 1')
    write_capacity=$(echo "$table_info" | jq -r '.ProvisionedThroughput.WriteCapacityUnits // 1')
    
    # Get autoscaling settings
    read_autoscaling=$(get_autoscaling_settings "$table" "read")
    write_autoscaling=$(get_autoscaling_settings "$table" "write")
    
    # Check if autoscaling is enabled
    autoscaling_enabled=$([ -n "$read_autoscaling" ] || [ -n "$write_autoscaling" ] && echo "true" || echo "false")
    
    # Extract min and max capacities for autoscaling
    read_min_capacity=$(echo "$read_autoscaling" | jq -r '.[0].ScalableTargetAction.MinCapacity // 1')
    read_max_capacity=$(echo "$read_autoscaling" | jq -r '.[0].ScalableTargetAction.MaxCapacity // 10')
    write_min_capacity=$(echo "$write_autoscaling" | jq -r '.[0].ScalableTargetAction.MinCapacity // 1')
    write_max_capacity=$(echo "$write_autoscaling" | jq -r '.[0].ScalableTargetAction.MaxCapacity // 10')
    
    # Write table information to YAML file
    cat << EOF >> "$output_file"
- name: "$table"
  billing_mode: "$billing_mode"
  read_capacity: "$read_capacity"
  write_capacity: "$write_capacity"
  autoscaling_enabled: $autoscaling_enabled
  autoscaling_read:
    min_capacity: "$read_min_capacity"
    max_capacity: "$read_max_capacity"
  autoscaling_write:
    min_capacity: "$write_min_capacity"
    max_capacity: "$write_max_capacity"

EOF
done

echo "Export completed. Results saved to $output_file"