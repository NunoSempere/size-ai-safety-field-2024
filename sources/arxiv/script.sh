#!/bin/bash

rm -f authors.txt

# for (( start = 0; start <= 6400; start += 1000 )); do
for (( start = 0; start <= 64000; start += 1000 )); do
  # Build URL with the current start value
  url="https://export.arxiv.org/api/query?search_query=cat:stat.ML&start=${start}&max_results=1000"

  # Use curl to fetch the data
  echo 
  echo "Fetching data from ${start} to $((start + 999))"

  echo "curl -s "\"$url\"" | yq -p xml -oy '.feed.entry' -o=json | jq '.[] | select(.published | contains("2023")) | .author | if type=="array" then .[] | .name else .name end' | tee -a authors.txt"
  curl -s "$url" | yq -p xml -oy '.feed.entry' -o=json | jq '.[] | select(.published | contains("2023")) | .author | if type=="array" then .[] | .name else .name end'  | tee -a authors.txt

  echo "Sleeping 3 secs"
  sleep 3

done

echo "Number of authors: $(cat authors.txt | uniq | wc -l)"
