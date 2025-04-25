#!/bin/bash

CSV_FOLDER="${2:-./subject/customer}"
DB_USR="pnopjira"
DB_NAME="piscineds"
DB_HOST="localhost"

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

#Import data
import_data_csv() {
    #check if table is not empty
    row_count=$(PGPASSWORD="$DB_PW" psql -U "$DB_USR" -d "$DB_NAME" -h "$DB_HOST" -Atc \
    "SELECT COUNT(*) FROM $1;")
    if [ $row_count -gt 0 ]; then
        echo "⏭️ $1 -- Already filled -- skipped"
        return 1
    fi
    PGPASSWORD="$DB_PW" psql -U "$DB_USR" -d "$DB_NAME" -h "$DB_HOST" -c "\copy $1 FROM $2 DELIMITER ',' CSV HEADER"
}

#loop all CSV files in folder
for csv_file in "$CSV_FOLDER"/*.csv; do
   
    if [ {$file_name} = {$table_name} ]; then
        echo "✅ Table '$file_name' exists!"
        #import data
        import_data_csv "$file_name" "$csv_file"
    else
        echo "❌ Table '$file_name' doesn't exist!"
        #Cearte table
        PGPASSWORD="$DB_PW" psql -U "$DB_USR" -d "$DB_NAME" -h "$DB_HOST" -c \
        "
            CREATE TABLE $file_name (
                event_time TIMESTAMPTZ,
                event_type TEXT,
                product_id INTEGER,
                price NUMERIC(10,2),
                user_id BIGINT,
                user_session UUID
            );
        "
        #import data
        import_data_csv "$file_name" "$csv_file"
    fi
    #check import status
    if [ $? = 0 ]; then
        echo -e  "✅ Import Data Sucessful!\n"
    else
        echo -e "❌ Import Data Failure!\n"
    fi
done
