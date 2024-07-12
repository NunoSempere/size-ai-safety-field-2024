https://info.arxiv.org/help/api/user-manual.html

curl export.arxiv.org/api/query?search_query=cat:stat.ML

curl "export.arxiv.org/api/query?search_query=cat:stat.ML&start=0&max_results=1000"

https://github.com/mikefarah/yq
wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq &&\
    chmod +x /usr/bin/yq

yq -oy '.' query.xml

yq -oy '.' query.xml -j
yq -oy '.feed.entry' query.xml -j

yq -oy '.feed.entry' query.xml -o=json

yq -oy '.feed.entry' query.xml -o=json | jq '.[] | select(.published | contains("2007"))'

yq -oy '.feed.entry' query.xml -o=json | jq '.[] | select(.published | contains("2007"))' | jq .author


yq -oy '.feed.entry' query.xml -o=json | jq '.[] | select(.published | contains("2007"))' | jq .author | jq '.[] | .name'

yq -oy '.feed.entry' query.xml -o=json | jq '.[] | select(.published | contains("2007"))' | jq .author | jq 'if type=="array" then "yes" else "no" end'

yq -oy '.feed.entry' query.xml -o=json | jq '.[] | select(.published | contains("2007"))' | jq .author | jq 'if type=="array" then .[] | .name else .name end'

 yq -p xml

curl -s "export.arxiv.org/api/query?search_query=cat:stat.ML&start=0&max_results=100" | yq -p xml 

curl -s "export.arxiv.org/api/query?search_query=cat:stat.ML&start=0&max_results=100" | yq -p xml -oy '.feed.entry' query.xml -o=json


curl -s "export.arxiv.org/api/query?search_query=cat:stat.ML&start=0&max_results=100" | yq -p xml -oy '.feed.entry' -o=json | jq .author | jq 'if type=="array" then .[] | .name else .name end'


curl -s "export.arxiv.org/api/query?search_query=cat:stat.ML&start=0&max_results=100" | yq -p xml -oy '.feed.entry' -o=json | jq '.[] | select(.published | contains("2007"))' | jq .author | jq 'if type=="array" then "yes" else "no" end' | jq .author | jq 'if type=="array" then .[] | .name else .name end'

curl -s "export.arxiv.org/api/query?search_query=cat:stat.ML&start=0&max_results=100" | yq -p xml -oy '.feed.entry' -o=json | jq '.[] | select(.published | contains("2007"))' | jq .author | jq 'if type=="array" then .[] | .name else .name end'


