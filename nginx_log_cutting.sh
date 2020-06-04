#!/bin/bash
# --------------------------------------------------------------------------------------------
# Filename:      nginx_log_cutting.sh
# Version:       2.0
# Date:          2017.4.10
# Author:        hyb
# Description:   nginx 日志切割、打包、删除过期压缩包脚本
# Notes:         配合 crontab 计划任务，每天零时对日志打包
#                0 0 * * * /bin/bash [PATH]/nginx_log_cutting.sh /var/www/project &> /dev/null
# --------------------------------------------------------------------------------------------

# nginx 进程 id,通常是 /var/run/nginx.pid
nginx_pid="/var/run/nginx.pid";
# 项目日志目录
log_dir="";
# access文件名
access_log='access.log';
# error文件名
error_log="error.log";
# 昨天日期
yesterday=$(date -d 'yesterday' +%Y%m%d);    # 生产
#yesterday=$(date -d 'today' +%Y%m%d%H%M);    # 测试
# access压缩包正则
access_name="access-*.tar.gz";
# error压缩包正则
error_name="error-*.tar.gz";
# 压缩包过期时间
log_expire=14;

# 检测 nginx_pid 文件是否存在
if [ ! -e $nginx_pid ];then
    echo "failed, $nginx_pid not exists!";exit 1;
fi

# 检测命令参数，是否传递日志目录
if [ -z $1 ];then
    echo "failed, missing parameter log_dir! command like, ./nginx_log_cutting.sh /var/log/project/";exit 2;
fi

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

echo "success, nginx log cut!";exit 0;
