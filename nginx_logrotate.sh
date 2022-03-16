#!/bin/bash

# .log 日志文件名
access_log='access.log';
error_log="error.log";

# .tar.gz 日志压缩包名
access_name="access-*.tar.gz";
error_name="error-*.tar.gz";

# 压缩包过期时间
log_expire=14;

# 打包时间
yesterday=$(date -d 'yesterday' +%Y%m%d);    # 生产
#yesterday=$(date -d 'today' +%Y%m%d%H%M);    # 测试

# 检测 nginx_pid 文件是否存在，通常是 /var/run/nginx.pid
nginx_pid="/var/run/nginx.pid";
if [ ! -e $nginx_pid ];then
    echo "failed, $nginx_pid not exists!";exit 1;
fi

# 检测命令参数，是否传递日志目录
if [ -z $1 ];then
    echo "failed, missing parameter log_dir! command like, ./nginx_log_cutting.sh /var/log/project/";exit 2;
fi

# 项目日志目录
log_dir=$1;
# 检测日志目录是否存在
if [ ! -d $log_dir ];then
    echo "failed, $log_dir not exists!";exit 3;
fi

cd $log_dir;

# 检测日志文件是否存在
if [ ! -e $access_log ];then
    echo "failed, $access_log not exists!";exit 4;
fi
if [ ! -e $error_log ];then
    echo "failed, $error_log not exists!";exit 5;
fi

# 日志切割
mv ./$access_log ./access-${yesterday}.log;
mv ./$error_log ./error-${yesterday}.log;

# 信号通知 nginx 新建日志文件
kill -USR1 `cat $nginx_pid`;

# 打包压缩日志
tar -zcf access-${yesterday}.tar.gz access-${yesterday}.log --remove-file
tar -zcf error-${yesterday}.tar.gz error-${yesterday}.log --remove-file

access_expire=$(($(ls $access_name | wc -l 2> /dev/null) - $log_expire));
error_expire=$(($(ls $error_name | wc -l 2> /dev/null) - $log_expire));

# 压缩包数量维护
if [ $access_expire -gt 0 ];then
    ls -rtd $access_name | head -n $access_expire | xargs rm -f;
fi
if [ $error_expire -gt 0 ];then
    ls -rtd $error_name | head -n $error_expire | xargs rm -f;
fi

echo "success" && exit 0