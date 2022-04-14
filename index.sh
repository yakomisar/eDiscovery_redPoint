#!/bin/sh

echo "Please specify folder for scanning..."
read index_folder
echo "Indexing folder ${index_folder}"

docker run -ti --net datashare_back -v /Users/olegkomisarenko/Desktop/datashare/my_data:/home/datashare/data icij/datashare:10.2.1 --mode CLI --stages INDEX --ocr true --parserParallelism 12 --defaultProject test --redisAddress redis://172.25.0.2:6379 --queueName t2 --reportName r2 --elasticsearchAddress http://172.25.0.4:9200 --messageBusAddress 172.25.0.2 --dataSourceUrl "jdbc:postgresql://172.25.0.3:5432/dsbase?user=postgres&password=strongpwd"