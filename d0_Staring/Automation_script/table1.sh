#!/bin/bash

DB_USER="pnopjira"
DB_NAME="piscineds"
DB_HOST="localhost"
CONTAINER_NAME="postgres_container"

CSV_FOLDER="${2:-./subject/customer/}"
TABLE_NAME="$1"
CREATE_TABLE_STATUS=1

is_valid_csv_name() {
    # The CSV’s name, without the file extension
    csv_name=$(basename "$1" .csv | tr '-' '_' | tr '[:upper:]' '[:lower:]')
    # Allow only valid CSV names, otherwise return 1
    [[ "$csv_name" =~ ^[a-zA-Z0-9_]+$ ]] || return 1
    # Allow only Arg. that match with CSV names
    [[ "$csv_name" == "$TABLE_NAME" ]] || return 1
    return 0
}

for  file_path in "$CSV_FOLDER"/*.csv; do
    if is_valid_csv_name "$file_path"; then
        table_exists=$(docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -tAc "SELECT to_regclass('$TABLE_NAME');")
        # Check DB table is already exists
        if [[ -z "$table_exists" || "$table_exists" == "null" ]]; then
            docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -c \
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
    return 1
fi
