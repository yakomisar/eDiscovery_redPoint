#!/bin/sh

echo "Datashare starting..."
sleep 1

datashare_version="10.2.1"
redis_image="redis:4.0.1-alpine"
postgres_image="postgres:10.20"
elastic_image="elasticsearch:7.9.1"

create_docker_compose_file () {
cat > docker-compose.yaml << EOF
version: '3.1'

services:
  redis:
    image: redis:4.0.1-alpine
    container_name: redis
    ports:
        - "6379:6379"
    networks:
      back:
        ipv4_address: 172.25.0.2
    restart: on-failure

  postgres:
    image: postgres:10.20
    container_name: postgres
    volumes:
      - ./pg_data:/var/lib/postgres/data/pgdata
    ports:
      - "5432:5432"
    networks:
      back:
        ipv4_address: 172.25.0.3
    environment:
      - "POSTGRES_DB=dsbase"
      - "POSTGRES_USER=postgres"
      - "POSTGRES_PASSWORD=strongpwd"
    restart: on-failure

  elasticsearch:
    image: elasticsearch:7.9.1
    container_name: elastic
    volumes:
      - ./elastic_index:/usr/share/elasticsearch/data
    ports:
        - "9200:9200"
    networks:
      back:
        ipv4_address: 172.25.0.4
    environment:
      - "discovery.type=single-node"
    restart: on-failure

networks:
    back:
        driver: bridge
        ipam:
            driver: default
            config:
                - subnet: 172.25.0.0/24
                  gateway: 172.25.0.1
EOF
}
create_docker_compose_file
docker-compose -p datashare up -d

echo "Docker has been successfully launched."
redis_id=$(docker ps -aqf "name=redis")
docker exec -it ${redis_id} redis-cli set admin '{"uid":"admin", "password":"8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918", "groups_by_applications":{"datashare": ["test"]}}}'
echo "Default record for redis with name/password: admin/admin has been created."

docker run -p 8080:8080 --net datashare_back -v /Users/olegkomisarenko/Desktop/datashare/user_data:/home/datashare/data -ti icij/datashare:10.2.1 --mode SERVER --redisAddress redis://172.25.0.2:6379 --elasticsearchAddress http://172.25.0.4:9200 --messageBusAddress 172.25.0.2 --dataSourceUrl "jdbc:postgresql://172.25.0.3:5432/dsbase?user=postgres&password=strongpwd" --rootHost localhost:8080 --authFilter org.icij.datashare.session.BasicAuthAdaptorFilter

echo "Datashare has been successfully launched."
