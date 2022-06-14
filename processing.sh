#!/bin/sh

# Environment variables 
datashare_version="10.2.1"
default_project="test"
redis_address="172.25.0.2:6379"
bar_code="t1"
report_name="r1"
elastic_address="http://172.25.0.4:9200"
messagebus_address="172.25.0.2"
postgres_address="jdbc:postgresql://172.25.0.3:5432/dsbase?user=postgres&password=strongpwd"

echo "Please specify folder for processing..."
read processing_folder
echo "Please check the following credentials that will be used for launching..."
echo "Processing folder: ${processing_folder}"
echo "Project name: ${default_project}"
echo "Datashare version: ${datashare_version}"
echo "Redis_address: ${redis_address}"
echo "Elastic address: ${elastic_address}"
echo "Message Bus address: ${messagebus_address}"
echo "Postgres address: ${postgres_address}"
echo "Barcode or custodian name: ${bar_code}"
echo "Report name: ${report_name}"

sleep 5


docker run -ti --net datashare_back -v ${processing_folder}:/home/datashare/data icij/datashare:${datashare_version} --mode CLI --stages INDEX --ocr true --parserParallelism 12 --defaultProject ${default_project} --redisAddress redis://${redis_address} --queueName ${bar_code} --reportName ${report_name} --elasticsearchAddress ${elastic_address} --messageBusAddress ${messagebus_address} --dataSourceUrl "${postgres_address}"