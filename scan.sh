#!/bin/sh

echo "Please specify folder for scanning..."
read scan_folder
echo "Scanning folder ${scan_folder}"
docker run -ti --net datashare_back -v ${scan_folder}:/home/datashare/data icij/datashare:10.2.1 --mode CLI --stages SCAN -d /home/datashare/data --redisAddress redis://172.25.0.2:6379 --defaultProject test --queueName t2
