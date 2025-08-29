#!/bin/bash

# Установка переменных
DOCKER_DIR="/opt/docker"
ZIP1="eily-acuario-docker-compose-main.zip"
ZIP2="OSM-Tile-Server-Backup.zip"
OSM_FILE=$(ls *.osm.pbf 2>/dev/null)
RED='\033[0;31m'
NC='\033[0m'
#Проверка на наличие файлов в директории скрипта
#curl -L -o eily-acuario-docker-compose-main.zip https://gitlab.integra-s.com/devops/eily-acuario-docker-compose/-/archive/main/eily-acuario-docker-compose-main.zip
if [[! -f "$ZIP1"]]; then
    echo -e "$RED Ошибка. Архив с докером отсутствует $NC"
    exit 1
fi
# Создание папки docker и распаковка первого архива
echo "Создание папки $DOCKER_DIR..."
mkdir -p "$DOCKER_DIR"

echo "Распаковка архива $ZIP1 в $DOCKER_DIR..."
unzip -o "$ZIP1" -d "$DOCKER_DIR"

# Отладка
if [ $? -eq 0 ]; then
    echo "Архив $ZIP1 успешно распакован."
else
    echo "Ошибка при распаковке $ZIP1."
    exit 1
fi

# Запрос на создание папки osm
read -p "Хотите создать папку osm в $DOCKER_DIR? (Y/y для да, любое другое для нет): " create_osm

if [[ "$create_osm" == "Y" || "$create_osm" == "y" ]]; then
    OSM_DIR="$DOCKER_DIR/osm"
    echo "Создание папки $OSM_DIR..."
    mkdir -p "$OSM_DIR"

    echo "Распаковка архива $ZIP2 в $OSM_DIR..."
    unzip -o "$ZIP2" -d "$OSM_DIR"

    # Отладка
    if [ $? -eq 0 ]; then
        echo "Архив $ZIP2 успешно распакован."
    else
        echo -e "$RED Ошибка при распаковке $ZIP2. $NC"
        exit 1
    fi

    # Шаг 3: Запрос на копирование файла .osm.pbf
    if [ -n "$OSM_FILE" ]; then
        read -p "Хотите скопировать файл $OSM_FILE в $OSM_DIR? (Y/y для да, любое другое для нет): " copy_osm_file

        if [[ "$copy_osm_file" == "Y" || "$copy_osm_file" == "y" ]]; then
            echo "Копирование файла $OSM_FILE в $OSM_DIR..."
            cp "$OSM_FILE" "$OSM_DIR"

            # Отладка
            if [ $? -eq 0 ]; then
                echo "Файл $OSM_FILE успешно скопирован в $OSM_DIR."
            else
                echo -e  "$RED Ошибка при копировании файла $OSM_FILE. $NC"
            fi
        else
            echo "Файл $OSM_FILE не был скопирован."
        fi
    else
        echo "Файл с расширением .osm.pbf не найден в текущей директории."
    fi
else
    echo "Папка osm не была создана."
fi
