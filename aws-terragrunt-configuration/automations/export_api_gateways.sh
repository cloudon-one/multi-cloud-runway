#!/bin/bash

set -e

# Set default region
AWS_DEFAULT_REGION="eu-west-1"
export AWS_DEFAULT_REGION

# Function to convert string to lowercase
to_lowercase() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

# Function to sanitize resource path for method name
sanitize_path() {
    echo "$1" | tr -c '[:alnum:]' '_' | tr '[:upper:]' '[:lower:]'
}

# Function to safely process JSON with jq
safe_jq() {
    echo "$1" | jq -r "$2" 2>/dev/null || echo "N/A"
}

# Get list of API Gateway IDs
api_ids=$(aws apigateway get-rest-apis --query 'items[*].id' --output text)

# Start the YAML file
echo "api_gateways:" > api_gateways.yaml

for api_id in $api_ids; do
    # Get API details
    api_details=$(aws apigateway get-rest-api --rest-api-id "$api_id")
    name=$(safe_jq "$api_details" '.name')
    description=$(safe_jq "$api_details" '.description')
    
    # Get stage information
    stages=$(aws apigateway get-stages --rest-api-id "$api_id")
    stage=$(safe_jq "$stages" '.item[0].stageName')
    
    # Get domain name (if available)
    domain_names=$(aws apigateway get-domain-names)
    domain_name=$(safe_jq "$domain_names" ".items[] | select(.apiMappings[].apiId == \"$api_id\") | .domainName")
    
    # Get endpoint configuration
    endpoint_type=$(safe_jq "$api_details" '.endpointConfiguration.types[0]')
    
    # Get ACM certificate ARN (if available)
    acm_certificate_arn=$(safe_jq "$domain_names" ".items[] | select(.domainName == \"$domain_name\") | .regionalCertificateArn")
    
    # Get tags
    tags=$(aws apigateway get-tags --resource-arn "arn:aws:apigateway:$AWS_DEFAULT_REGION::/restapis/$api_id")
    
    # Get resources
    resources=$(aws apigateway get-resources --rest-api-id "$api_id")
    
    # Write API Gateway info to YAML
    cat << EOF >> api_gateways.yaml
  - name: "$name"
    description: "$description"
    stage: "$stage"
    domain_name: "$domain_name"
    sqs_role_arn: "N/A"  # You may need to fetch this separately
    endpoint_configuration:
      type: ["$endpoint_type"]
      acm_certificate_arn: "$acm_certificate_arn"
    tags:
EOF
    
    safe_jq "$tags" '.tags | to_entries[] | "      \(.key): \"\(.value)\""' >> api_gateways.yaml
    
    echo "    resources:" >> api_gateways.yaml
    safe_jq "$resources" '.items[] | select(.pathPart != null) | "      - name: \"\(.pathPart)\"\n        parent_id: \"\(.parentId // "")\""' >> api_gateways.yaml
    
    echo "    methods:" >> api_gateways.yaml
    
    # Get methods for each resource
    safe_jq "$resources" '.items[] | select(.id != null and .path != null) | "\(.id) \(.path)"' | while read -r resource_id resource_path; do
        if [ -z "$resource_id" ] || [ -z "$resource_path" ]; then
            continue
        fi
        resource_methods=$(aws apigateway get-resource --rest-api-id "$api_id" --resource-id "$resource_id")
        safe_jq "$resource_methods" '.resourceMethods | keys[]' | while read -r http_method; do
            if [ -z "$http_method" ] || [ "$http_method" == "null" ]; then
                continue
            fi
            method_details=$(safe_jq "$resource_methods" ".resourceMethods[\"$http_method\"]")
            authorization=$(safe_jq "$method_details" '.authorizationType')
            method_name=$(to_lowercase "${http_method}")_$(sanitize_path "$resource_path")
            echo "      - name: \"$method_name\"" >> api_gateways.yaml
            echo "        resource: \"$resource_path\"" >> api_gateways.yaml
            echo "        http_method: \"$http_method\"" >> api_gateways.yaml
            echo "        authorization: \"$authorization\"" >> api_gateways.yaml
            echo "        sqs_name: \"N/A\"" >> api_gateways.yaml
            echo "        request_template: \"N/A\"" >> api_gateways.yaml
        done
    done
    
    echo "" >> api_gateways.yaml
done

echo "API Gateway information has been saved to api_gateways.yaml"