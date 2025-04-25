apt update && apt install wget -y

wget https://cdn.intra.42.fr/document/document/23498/subject.zip

unzip subject.zip

tar -c subject.tar ./subject



docker exec -i postgres_container psql -U pnopjira -d piscineds -h localhost <<EOF
SELECT COUNT(*) FROM data_2022_oct;
SELECT * FROM data_2022_oct LIMIT 3;
EOF
