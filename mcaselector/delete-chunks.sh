#!/bin/bash

# Delete old chunks based on a combination of
# LastUpdated
# InhabitedTime

# format: (LastUpdated, InhabitedTime)
declare -a delete_chunks=(
    ("30 days" "2 hours")
    ("7 days" "1 hours")
    ("12 hours" "15 minutes")
    ("1 hour" "5 minutes")
)

# create group string based on array
group_string=""
for condition in "${delete_chunks[@]}"; do
    IFS=' ' read -r last_updated inhabited_time <<< "$condition"
    group_string+="(LastUpdated >= $last_updated AND InhabitedTime >= $inhabited_time) OR "
done
group_string=${group_string% OR }

java -jar /mcaselector/MCASelector.jar \
    --mode delete \
    --world /minecraft/world \
    --query "$group_string"
