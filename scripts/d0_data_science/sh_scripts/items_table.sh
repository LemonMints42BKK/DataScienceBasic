DB_PATH="/data/subject/item/item.csv"
DB_USR="pnopjira"
DB_NAME="piscineds"
DB_HOST="localhost"
DB_PW="mysecretpassword"
TABLE_NAME='items'

#Import data
import_data_csv() {
    #check if table is not empty
    row_count=$(PGPASSWORD="$DB_PW" psql -U "$DB_USR" -d "$DB_NAME" -h "$DB_HOST" -Atc \
    "SELECT COUNT(*) FROM $TABLE_NAME;")
    if [ $row_count -gt 0 ]; then
        echo "⏭️ $TABLE_NAME -- Already filled -- skipped"
        return 1
    fi
    PGPASSWORD="$DB_PW" psql -U "$DB_USR" -d "$DB_NAME" -h "$DB_HOST" -c "\copy $TABLE_NAME FROM $DB_PATH DELIMITER ',' CSV HEADER"
}

#Cearte table
PGPASSWORD="$DB_PW" psql -U "$DB_USR" -d "$DB_NAME" -h "$DB_HOST" -c \
"
    CREATE TABLE IF NOT EXISTS $TABLE_NAME (
        product_id INTEGER NOT NULL,
        category_id BIGINT,
        category_code TEXT,
        brand VARCHAR(255)
    );
"
# import data
import_data_csv