#!/bin/bash

DB_USR="pnopjira"
DB_NAME="piscineds"
DB_HOST="localhost"
CONTAINER_NAME="postgres_container"

CSV_FOLDER="${1:-./subject/customer/}"

#Import data
import_data_csv() {
    table_name="$1"
    #check if table is not empty
    row_count=$(docker exec -i "$CONTAINER_NAME" psql -U "$DB_USR" -d "$DB_NAME" -h "$DB_HOST" -Atc \
    "SELECT COUNT(*) FROM $table_name;")
    echo "DEBUG: $row_count , $table_name, $CSV_FOLDER"

    if [ $row_count -gt 0 ]; then
        docker exec -i "$CONTAINER_NAME" psql -U "$DB_USR" -d "$DB_NAME" -h "$DB_HOST" -c "DROP TABLE $table_name;"
        ./table1.sh "$table_name" "$CSV_FOLDER"
        import_data_csv "$table_name"
    fi
    cat "$CSV_FOLDER/$table_name.csv" | docker exec -i "$CONTAINER_NAME" \
    psql -U "$DB_USR" -d "$DB_NAME" -h "$DB_HOST" \
    -c "COPY $table_name FROM STDIN WITH CSV HEADER DELIMITER ',';"
    return 0
}

# loop all CSV files in folder
for csv_path in "$CSV_FOLDER"/*.csv; do
    # Get csv filename
    table_name=$(basename "$csv_path" .csv | tr '-' '_' | tr '[:upper:]' '[:lower:]')
    # Allow only valid CSV names
    [[ "$table_name" =~ ^[a-zA-Z0-9_]+$ ]] || continue
    # Generate table
    ./table1.sh "$table_name" "$CSV_FOLDER"
    if [ $? = 1 ]; then
        continue
    fi
    # Import date to table
    echo "START"
    import_data_csv "$table_name"
    echo "END"
    #check import status
    if [ $? = 0 ]; then
        echo -e  "✅ Import Data Sucessful!\n"
    else
        echo -e "❌ Import Data Failure!\n"
    fi
done
