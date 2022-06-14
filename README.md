# __Datashare server startup guide__

#### Убедитесь, что у вас установлен Docker и Docker-compose. Создайте директорию проекта (например: __case001__), перейдите в нее и дополнительно создайте три папки:
`mkdir pg_data elastic_search user_data`
- - - -

### __Выберите свою операционную систему и следуйте инструкциям__

> __MAC OS__

В директорию проекта необходимо скопировать данные с репозитория в формате *.sh файлов, которые необходимо запускать в указанной последовательности.
Шаг | Название файла  | Содержание | Команда для запуска
------------- | ------------- | ------------- | -------------
__1__ | start.sh  | Скрипт для создания докер-контейнера, который состоит из Redis, Elasticsearch и Postgresql | `sh start.sh`
__2__ | scan.sh  | Скрипт индексации пользовательских данных, которые необходимо запроцессить | `sh scan.sh`
__3__ | processing.sh  | Скрипт процессинга данных, которые были проиндексированы на Шаге 2| `sh processing.sh`

Давайте подробно рассмотрим и разберем каждый шаг в отдельности для более тонкой настройки:
### __Шаг 1__ - `start.sh`
По сути самый важный шаг - скачивает/запускает компоненты/контейнеры системы необходимые для корректной работы Datashare. Представляет собой Docker-compose file.
После запуска данного скрипта, необходимо будет указать путь к папке __user_data__, которая была создана ранее.
Более подробное остановимся на некоторых фрагментах кода.
#### __Строки 1-72__
Происходит создание конфигурационного файла docker-compose. При желании можно изменить адрес виртуальной сети и адреса для каждого из контейнеров.
#### __Строки 70-72__
Здесь мы задаем пользователя __admin__ с паролем __admin__. При желании можно поменять как имя пользователя так и пароль. Пароль записывается в виде md5-hash. Кроме того, здесь мы указываем кейсы, к которым будет иметь доступ наш пользователь (пример: __test__).
```sh
redis_id=$(docker ps -aqf "name=redis")
docker exec -it ${redis_id} redis-cli set admin '{"uid":"admin", "password":"8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918", "groups_by_applications":{"datashare": ["test"]}}}'
echo "Default record for redis with name/password: admin/admin has been created."
```
### __Шаг 2__ - `scan.sh`
После запуска скрипта - будет предложено выбрать путь до папки, в которой лежат данные, которые необходимо проиндексировать. 
#### __Пример: /Users/<Имя пользователя>/Desktop/Datashare/user_data__
Данную папку по-сути необходимо замаунтить в контейнер. Другие данные окружения вы можете самостоятельно изменить в файле scan.sh в разделе __Environment variables__. Ниже представлена часть скрипта с пояснениями.
#### __defaultProject__ - необходимо указать название проекта для которого выполняется сканирование документов. В нашем случае это __test__ (но может быть и __case001__).
#### __queueName__ - указываем любое наименование, но лучше практикой является назвать именем __custodian_name__.
```sh
#!/bin/sh
docker run -ti --net datashare_back
-v ${scan_folder}:/home/datashare/data # маунтим локальную папку в папку контейнера
icij/datashare:10.2.1 # указываем докер-образ соответсвующий вашей версии datashare
--mode CLI  # оставляем по умолчанию
--stages SCAN -d /home/datashare/data # оставляем по умолчанию
--redisAddress redis://172.25.0.2:6379 # указываем ip-адрес redis контейнера 
--defaultProject test # указываем название проекта
--queueName t1 # задаем наименование
```
### __Шаг 3__ - `processing.sh`
После запуска скрипта - будет предложено выбрать путь до папки, в которой лежат данные, которые необходимо запроцессить. Путь до папки совпадает с путем по которому мы выполняли Шаг2. __Пример: /Users/<Имя пользователя>/Desktop/Datashare/user_data__
Ниже представлена часть скрипта с пояснениями.
```sh
#!/bin/sh
docker run -ti --net datashare_back \
-v ${processing_folder}:/home/datashare/data # маунтим папку, которая была просканирована на Шаге 2 в папку контейнера
icij/datashare:10.2.1 # указываем докер-образ соответсвующий вашей версии datashare
--mode CLI # оставляем по умолчанию
--stages INDEX # оставляем по умолчанию
--ocr true # оставляем по умолчанию
--parserParallelism 12 # оставляем по умолчанию
--defaultProject test # указываем название проекта
--redisAddress redis://172.25.0.2:6379 # указываем ip-адрес redis контейнера с указанием порта
--queueName t1 # указываем любое наименование, но лучше практикой является назвать именем __custodian_name__.
--reportName r1 # указываем любое наименование
--elasticsearchAddress http://172.25.0.4:9200 # указываем ip-адрес elasticsearch контейнера 
--messageBusAddress 172.25.0.2 # указываем ip-адрес redis-контейнера без указания порта
--dataSourceUrl "jdbc:postgresql://172.25.0.3:5432/dsbase?user=postgres&password=strongpwd" # указываем адрес postgres с указанием имени и пароля
```
- - - -
> __Ubuntu 18:10__