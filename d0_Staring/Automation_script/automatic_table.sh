#!/bin/bash

DB_PATH="../subject/customer"
DB_USR="pnopjira"
DB_NAME="piscineds"
DB_HOST="localhost"
DB_PW="mysecretpassword"

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

#chack file name exiting
for csv_file in "$DB_PATH"/*.csv; do
    file_name=$(basename "$csv_file" .csv | tr '-' '_' | tr '[:upper:]' '[:lower:]')
    echo "Chack extites $file_name table"
    table_name=$(PGPASSWORD="$DB_PW" psql -U "$DB_USR" -d "$DB_NAME" -h "$DB_HOST" -Atc "SELECT to_regclass('$file_name');")
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