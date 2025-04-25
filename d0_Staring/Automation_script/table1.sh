#!/bin/bash

DB_USER="pnopjira"
DB_NAME="piscineds"
DB_HOST="localhost"
CSV_FOLDER="${2:-./subject/customer}"
TABLE_NAME="$1"
CREATE_TABLE_STATUS=1

get_container_id() {
    # Get the container ID of the PostgreSQL container (assuming it's named something like 'postgres')
    postgres_container_id=$(docker ps -q --filter "name=postgres_container")
    # Check if the container exists
    if [ -z "$postgres_container_id" ]; then
        echo " ❌ PostgreSQL container is not running."
        exit 1
    fi
    echo "✅ PostgreSQL container ID is $postgres_container_id"
}

is_valid_csv_name() {
    # The CSV’s name, without the file extension
    csv_name=$(basename "$1" .csv | tr '-' '_' | tr '[:upper:]' '[:lower:]')
    # Allow only valid CSV names, otherwise return 1
    [[ "$csv_name" =~ ^[a-zA-Z0-9_]+$ ]] || return 1
    # Allow only Arg. that match with CSV names
    [[ "$csv_name" == "$TABLE_NAME" ]] || return 1
    return 0
}

get_container_id

for  file_path in "$CSV_FOLDER"/*.csv; do
    # if is_valid_csv_name "$file_path"; then
    #     echo "✅ CSV is valid"
    #     CREATE_TABLE_STATUS=0
    # else
    #     echo "❌ CSV is invalid"
    # fi

    if is_valid_csv_name "$file_path"; then
        table_exists=$(docker exec -i "$postgres_container_id" psql -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -tAc "SELECT to_regclass('$TABLE_NAME');")
        echo "DEBUG: table_exists='$table_exists'"
        # Check DB table is already exists
        if [[ -z "$table_exists" || "$table_exists" == "null" ]]; then
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
            echo "⏭️ Table '$TABLE_NAME' already exists. Skipping creation."
        fi
        CREATE_TABLE_STATUS=0
    fi
done

if [ $CREATE_TABLE_STATUS -eq 1 ]; then
    echo " ❌ Table name's $TABLE_NAME doesn't match with the CSV’s name "
	echo -e " ❌ OR The CSV folder path $CSV_FOLDER is incurrect\n"
fi 