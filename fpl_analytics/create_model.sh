#!/bin/bash

# Check if a model name was provided
if [ -z "$1" ]; then
    echo "Error: Please provide a model name"
    echo "Usage: ./create_dbt_model.sh <model_name>"
    exit 1
fi

MODEL_NAME="$1"

# Create the SQL file
cat > "${MODEL_NAME}.sql" << 'EOF'
with 
source as (
    select *
    from {{ source("", "") }}
    from {{ ref("") }}
)

select * from source
EOF

# Create the YAML file
cat > "${MODEL_NAME}.yml" << EOF
version: 2

models:
  - name: ${MODEL_NAME}
    description: DESCRIPTION
    tags: ["untagged"]
EOF

echo "Created ${MODEL_NAME}.sql and ${MODEL_NAME}.yml"