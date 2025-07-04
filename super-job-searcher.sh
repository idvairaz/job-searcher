#!/bin/sh


if [ $# -eq 0 ]; then
    echo "Как искать вакансии: $0 \"название вакансии в кавычках\" [регион_id](опционально, по умолчанию вся Россия) [\" название выходного_файла.csv в кавычках\"](опционально, по умолчанию hh.csv) [количество_вакансий](опционально, по умолчанию 20)" >&2
    echo "Пример использования: $0 \"java developer\" 1 vacancies.csv 35" >&2
    echo "Примеры регионов: 1-Москва, 2-СПб, 3-Екатеринбург, 4-Новосибирск, 113-Россия" >&2
    echo "Список id всех регионов можно найти по адресу  https://api.hh.ru/areas" >&2
    echo "Вы можете указать не все параметры, но важно соблюдать их порядок: сначала название, затем регион, файл и количество вакансий.Примеры:
   $0 \"разработчик\" 
   $0 \"разработчик\" 113 
   $0 \"разработчик\" 113 result.csv
   $0 \"разработчик\" 113 result.csv 50" >&2
    exit 1
fi


SEARCH_TEXT="$1"  
REGION="${2:-113}"
OUTPUT_CSV="${3:-hh.csv}"
PER_PAGE="${4:-20}"


SEARCH_STRING="\"$SEARCH_TEXT\""
ENCODED_TEXT=$(echo "$SEARCH_STRING" | jq -Rr @uri)


URL="https://api.hh.ru/vacancies?text=name:($ENCODED_TEXT)&area=$REGION&per_page=$PER_PAGE"


TEMP_JSON=$(mktemp)
echo "Поиск вакансии: '$SEARCH_TEXT'"
echo "Регион: $REGION"
echo "URL запроса: $URL"

curl -s -k -H "User-Agent: hh-job-searcher/1.0" "$URL" | jq '.' > "$TEMP_JSON"


echo "Преобразование результатов в CSV: $OUTPUT_CSV"
jq -r '
    ["id", "created_at", "name", "company", "city", "has_test", "alternate_url"] as $headers |
    $headers,
    (.items[] | [
        .id,
        .created_at,
        .name,
        .employer.name,   
        .area.name,
        .has_test,
        .alternate_url
    ]) |
    @csv
' "$TEMP_JSON" > "$OUTPUT_CSV"


# Статистика
VACANCIES_COUNT=$(jq '.items | length' "$TEMP_JSON" 2>/dev/null || echo 0)
CSV_LINES=$(wc -l < "$OUTPUT_CSV")

rm "$TEMP_JSON"

echo "Найдено вакансий: $VACANCIES_COUNT"
echo "Сохранено в CSV: $CSV_LINES строк (включая заголовок)"
echo "Результаты сохранены в $OUTPUT_CSV"

