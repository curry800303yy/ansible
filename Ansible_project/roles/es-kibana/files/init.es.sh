# 环境变量
ES_HOST=http://ES_Public_IP:9200
ES_USER=elastic
ES_PASS="ESPWlajKy5p137mOE9c2"
# 配置天数
EXPIRED_DAYS=7
# 索引默认配置，传入的值将覆盖默认配置, 请保持逗号结束，比如单机时，number_of_replicas 的值应为0 => "number_of_replicas":0,
# INDEX_SETTING='"number_of_shards":1,"number_of_replicas":0,'
INDEX_SETTING='"number_of_replicas":0,'

# 删除
echo "[delete] access_logs-empty"
curl -X DELETE -k "$ES_HOST/access_logs-empty?pretty&ignore_unavailable=true" -u "$ES_USER:$ES_PASS"
echo -e "\n[delete] block_logs-empty"
curl -X DELETE -k "$ES_HOST/block_logs-empty?pretty&ignore_unavailable=true" -u "$ES_USER:$ES_PASS"
echo -e "\n[delete] error_logs-empty"
curl -X DELETE -k "$ES_HOST/error_logs-empty?pretty&ignore_unavailable=true" -u "$ES_USER:$ES_PASS"
echo -e "\n[delete] api_logs-empty"
curl -X DELETE -k "$ES_HOST/api_logs-empty?pretty&ignore_unavailable=true" -u "$ES_USER:$ES_PASS"


# 创建策略
curl -X GET -k $ES_HOST'/_ilm/policy/logs-'$EXPIRED_DAYS'days-policy' -u "$ES_USER:$ES_PASS" -s | grep -q 404
if [ $? -eq 0 ]; then
  echo -e "\n[create] logs-"$EXPIRED_DAYS"days-policy policy"
  curl -X PUT -k $ES_HOST'/_ilm/policy/logs-'$EXPIRED_DAYS'days-policy?pretty' -H "Content-Type:application/json" -u $ES_USER:$ES_PASS -d '
  {
    "policy": {
      "phases": {
        "hot": {"actions": {}},
        "delete": {"min_age": "'$EXPIRED_DAYS'd","actions": {"delete": {}}}
      }
    }
  }'
fi
curl -X GET -k $ES_HOST'/_ilm/policy/logs-empty-keep-policy' -u "$ES_USER:$ES_PASS" -s | grep -q 404
if [ $? -eq 0 ]; then
  echo -e "\n[create] logs-empty-keep-policy policy"
  curl -X PUT -k $ES_HOST'/_ilm/policy/logs-empty-keep-policy?pretty' -H "Content-Type:application/json" -u $ES_USER:$ES_PASS -d '
  {
    "policy": {"phases": {"hot": {"actions": {}}}}
  }'
fi


# 创建模板
curl -X GET -k $ES_HOST'/_index_template/logs-'$EXPIRED_DAYS'days-template' -u "$ES_USER:$ES_PASS" -s | grep -q 404
if [ $? -eq 0 ]; then 
  echo -e "\n[create] logs-"$EXPIRED_DAYS"days-template template"
  curl -X PUT -k $ES_HOST'/_index_template/logs-'$EXPIRED_DAYS'days-template?pretty' -H "Content-Type:application/json" -u $ES_USER:$ES_PASS -d '
  {
    "index_patterns": ["*_logs-*"],
    "template": {"settings": {'$INDEX_SETTING'"index.lifecycle.name": "logs-'$EXPIRED_DAYS'days-policy"}},
    "priority": 10
  }'
fi
curl -X GET -k $ES_HOST'/_index_template/logs-empty-keep-template' -u $ES_USER:$ES_PASS -s | grep -q 404
if [ $? -eq 0 ]; then
  echo -e "\n[create] logs-empty-keep-template template"
  curl -X PUT -k $ES_HOST'/_index_template/logs-empty-keep-template?pretty' -H "Content-Type:application/json" -u $ES_USER:$ES_PASS -d '
  {
    "index_patterns": ["*_logs-empty"],
    "template": {"settings": {'$INDEX_SETTING'"index.lifecycle.name": "logs-empty-keep-policy"}},
    "priority": 20
  }'
fi


# 创建 access_logs 表
echo -e "\n[create] access_logs-empty"
curl -X PUT -k $ES_HOST'/access_logs-empty?pretty' -H "Content-Type:application/json" -u $ES_USER:$ES_PASS -d '
{
  "mappings":{
    "properties":{
      "app_id":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "app_name":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "auth_user":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "business_id":{"type":"long"},
      "city_id":{"type":"long"},
      "city_name":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "client_ip":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "content_type":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "country_id":{"type":"long"},
      "country_iso":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "country_name":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "created_time":{"type":"long"},
      "error":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "finish_time":{"type":"long"},
      "group_id":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "group_name":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "is_back_to_source":{"type":"boolean"},
      "is_hit_cache":{"type":"boolean"},
      "is_https":{"type":"boolean"},
      "is_waf_block":{"type":"boolean"},
      "is_white":{"type":"boolean"},
      "isp_id":{"type":"long"},
      "isp_name":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "ja3_hash":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "proto":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "referer":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "region_id":{"type":"long"},
      "region_name":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "remote_ip":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "request_body_bytes":{"type":"long"},
      "request_header_bytes":{"type":"long"},
      "request_host":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "request_http_header":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "request_id":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "request_method":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "request_path":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "request_uri":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "request_url":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "request_user_agent":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "response_body_bytes":{"type":"long"},
      "response_code":{"type":"long"},
      "response_header_bytes":{"type":"long"},
      "response_status":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "source_address":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "source_error":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "source_host":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "source_response_code":{"type":"long"},
      "source_response_header":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "source_response_status":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "source_response_time":{"type":"long"},
      "user_id":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "user_mail":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "user_name":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "waf_block_action":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "waf_node_ip":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "x_forwarded_for":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}}
    }
  }
}'

# 创建  block_logs 表
echo -e "\n[create] block_logs-empty"
curl -X PUT -k $ES_HOST'/block_logs-empty?pretty' -H "Content-Type:application/json" -u $ES_USER:$ES_PASS -d '
{
  "mappings":{
    "properties":{
      "action":{"type":"long"},
      "app_id":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "client_ip":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "created_time":{"type":"long"},
      "group_id":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "ja3_hash":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "message":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "policy_id":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "policy_type":{"type":"long"},
      "proto":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "reason":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "release_time":{"type":"long"},
      "request_host":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "request_id":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "request_method":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "request_uri":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "request_user_agent":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "response_http_header":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "source_address":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "user_id":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "waf_node_ip":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}}
    }
  }
}'

# 创建 error_logs 表
echo -e "\n[create] error_logs-empty"
curl -X PUT -k $ES_HOST'/error_logs-empty?pretty' -H "Content-Type:application/json" -u $ES_USER:$ES_PASS -d '
{
  "mappings":{
    "properties":{
      "contents":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "created_time":{"type":"long"},
      "level":{"type":"long"},
      "node_type":{"type":"long"},
      "time":{"type":"long"},
      "waf_node_ip":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}}
    }
  }
}'

# 创建 api_logs 表
echo -e "\n[create] api_logs-empty"
curl -X PUT -k $ES_HOST'/api_logs-empty?pretty' -H "Content-Type:application/json" -u $ES_USER:$ES_PASS -d '
{
  "mappings":{
    "properties":{
      "api":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "api_type":{"type":"long"},
      "client_ip":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "created_time":{"type":"long"},
      "request_body":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "request_header":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "response_body":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "response_code":{"type":"long"},
      "response_error":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}},
      "response_header":{"type":"text","fields":{"keyword":{"type":"keyword","ignore_above":256}}}
    }
  }
}'

