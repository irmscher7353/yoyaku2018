#!/bin/bash -l
# -*- coding: utf-8 -*-

TABLE=yoyaku2018_production

TS=$(date +"%Y%m%d")

cd ~ruby/Sites/yoyaku2018/db/backup

mysqldump -u ruby --password=$DATABASE_PASSWORD --opt $TABLE >${TABLE}-${TS}.mysql
