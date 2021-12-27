# nginx_logrotate
nginx 日志切割、打包、压缩包维护 shell

## Usage
- 路径依据各自服务器情况替换
```bash
0 0 * * * /bin/bash /data/sh/nginx_logrotate.sh /data/logs/nginx/$your_website_log_dir/ &> /dev/null
```

## 相关链接
[docker 版本](https://github.com/goindow/docker-nginx-logrotate)
