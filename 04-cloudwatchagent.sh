#!/bin/bash -ex

# 前提: CloudWatchAgentServerPolicyをつけたロール(WP-Role)を作り、インスタンスにアタッチ

# 前提: apacheインストール済み(/var/log/httpd/access_log, /var/log/httpd/error_logがあること)

# エージェントを導入
curl -sLO https://s3.ap-northeast-1.amazonaws.com/amazoncloudwatch-agent-ap-northeast-1/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
sudo rpm -U ./amazon-cloudwatch-agent.rpm

# 設定ファイルを作成
cat <<'EOF' |sudo tee /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
     "agent": {
         "metrics_collection_interval": 60,
         "run_as_user": "root"
     },
     "logs": {
         "logs_collected": {
             "files": {
                 "collect_list": [
                     {
                         "file_path": "/var/log/httpd/access_log",
                         "log_group_name": "access_log",
                         "log_stream_name": "{instance_id}"
                     },
                     {
                         "file_path": "/var/log/httpd/error_log",
                         "log_group_name": "error_log",
                         "log_stream_name": "{instance_id}"
                     }
                 ]
             }
         }
     },
     "metrics": {
         "append_dimensions": {
             "AutoScalingGroupName": "${aws:AutoScalingGroupName}",
             "ImageId": "${aws:ImageId}",
             "InstanceId": "${aws:InstanceId}",
             "InstanceType": "${aws:InstanceType}"
         },
         "metrics_collected": {
             "collectd": {
                 "metrics_aggregation_interval": 60
             },
             "disk": {
                 "measurement": [
                     "used_percent"
                 ],
                 "metrics_collection_interval": 60,
                 "resources": [
                     "*"
                 ]
             },
             "mem": {
                 "measurement": [
                     "mem_used_percent"
                 ],
                 "metrics_collection_interval": 60
             },
             "statsd": {
                 "metrics_aggregation_interval": 60,
                 "metrics_collection_interval": 10,
                 "service_address": ":8125"
             }
         }
     }
}
EOF

# Collectdのインストール
sudo amazon-linux-extras install -y epel && sudo yum -y install collectd

# エージェントの起動
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s
