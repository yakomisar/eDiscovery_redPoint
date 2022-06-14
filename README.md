# __Datashare server startup guide__

#### Убедитесь, что у вас установлен Docker и Docker-compose. Создайте директорию проекта (например: __case001__), перейдите в нее и дополнительно создайте три папки:
`mkdir pg_data elastic_search user_data`
- - - -

### __Выберите свою операционную систему и следуйте инструкциям__

> __MAC OS__

В директории вы найдете следующие файлы, которые необходимо запускать в представленной последовательности.
Шаг | Название файла  | Содержание | Команда для запуска
------------- | ------------- | ------------- | -------------
__1__ | start.sh  | Скрипт для создания докер-контейнера, который состоит из Redis, Elasticsearch и Postgresql | `sh start.sh`
__2__ | scan.sh  | Скрипт индексации пользовательских данных, которые необходимо запроцессить | `sh scan.sh`
__3__ | index.sh  | Скрипт процессинга данных, которые были проиндексированы | `sh index.sh`

Давайте подробно рассмотрим и разберем каждый шаг в отдельности для более тонкой настройки:
#### __Шаг 1__ - `start.sh`

#### __Шаг 2__ - `scan.sh`
```sh
#!/bin/sh
echo "Please specify folder for scanning..."
read scan_folder
echo "Scanning folder ${scan_folder}"
docker run -ti --net datashare_back \
-v ${scan_folder}:/home/datashare/data icij/datashare:10.2.1 \ 
--mode CLI --stages SCAN -d /home/datashare/data \
--redisAddress redis://172.25.0.2:6379 \
--defaultProject test --queueName t1`
```
#### __Шаг 3__ - `index.sh`

- - - -
> __Ubuntu 18:10__