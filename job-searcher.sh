#!/bin/sh

if [ $# -eq 0 ]; then
    echo "Ошибка: Не указана поисковая фраза - название вакансии" >&2
    echo "Надо: $0 \"название вакансии в кавычках\" [регион_id]" >&2
    echo "Примеры регионов: 1-Москва, 2-СПб, 3-Екатеринбург, 4-Новосибирск, 113-Россия" >&2
    echo "Список id всех регионов можно найти по адресу  https://api.hh.ru/areas, по умолчанию вся Россия" >&2
    echo "Пример использования: $0 \"java developer\" 1" >&2
    exit 1
fi


SEARCH_TEXT="$1"  
REGION="${2:-113}" #

SEARCH_STRING="\"$SEARCH_TEXT\""
ENCODED_TEXT=$(echo "$SEARCH_STRING" | jq -Rr @uri)


URL="https://api.hh.ru/vacancies?text=name:($ENCODED_TEXT)&area=$REGION&per_page=20"


echo "Поиск вакансии: '$SEARCH_TEXT'"
echo "Регион: $REGION"
echo "URL запроса: $URL"

curl -k -H "User-Agent: hh-job-searcher/1.0" "$URL" | jq '.' > hh.json

echo "Результаты сохранены в hh.json"
