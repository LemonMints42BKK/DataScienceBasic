#!/bin/bash

DB_USER="pnopjira"
DB_NAME="piscineds"
DB_HOST="localhost"
CSV_FOLDER="${2:-../subject/customer}"
TABLE_NAME="$1"
CREATE_TABLE_STATUS=1

# Get the container ID of the PostgreSQL container (assuming it's named something like 'postgres')
postgres_container_id=$(docker ps -q --filter "name=postgres_container")
# Check if the container exists
if [ -z "$postgres_container_id" ]; then
    echo " ❌ PostgreSQL container is not running."
    exit 1
fi

for  file_path in "$CSV_FOLDER"/*.csv; do
    # The CSV’s name, without the file extension
    csv_name=$(basename "$file_path" .csv | tr '-' '_' | tr '[:upper:]' '[:lower:]')
    # Ignore suspicious files name in loop
    [[ "$csv_name" =~ ^[a-zA-Z0-9_]+$ ]] || continue
    
    if [ "$TABLE_NAME" = "$csv_name" ]; then
        table_exists=$(docker exec -i "$postgres_container_id" psql -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -tAc "SELECT to_regclass('$TABLE_NAME');")
		# Create table when arg. is match with the CSV's name
        if [ -z "$table_exists" ]; then
            docker exec -i "$postgres_container_id" psql -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -c \
            "CREATE TABLE \"$TABLE_NAME\" (
                event_time TIMESTAMPTZ NOT NULL,
                event_type TEXT,
                product_id INTEGER,
                price NUMERIC(10,2),
                user_id BIGINT,
                user_session UUID
            );"
            echo "✅ Created new $TABLE_NAME table"
        else
            echo "⏭️Table '$TABLE_NAME' already exists. Skipping creation."
        fi
        CREATE_TABLE_STATUS=0
    fi
done

if [ $CREATE_TABLE_STATUS -eq 1 ]; then
    echo " ❌ Table name's $TABLE_NAME doesn't match with the CSV’s name "
	echo -e " ❌ OR The CSV folder path $TABLE_NAME is incurrect\n"
fi 