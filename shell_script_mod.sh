#!/usr/bin/env bash
## CUSTOM_SHELL_FILE for https://gitee.com/lxk0301/jd_docker/tree/master/docker
### 编辑docker-compose.yml文件添加: - CUSTOM_SHELL_FILE=https://raw.githubusercontent.com/monk-coder/dust/dust/shell_script_mod.sh
#### 容器完全启动后执行 docker exec -it jd_scripts /bin/sh -c 'crontab -l'

function monkcoder(){
    # https://github.com/monk-coder/dust
    rm -rf /monkcoder /scripts/monkcoder_*
    git clone https://ghproxy.com/https://github.com/monk-coder/dust /monkcoder
    # 拷贝脚本
    for jsname in $(find /monkcoder -name "*.js" | grep -vE "\/backup\/"); do cp ${jsname} /scripts/monkcoder_${jsname##*/}; done
    # 匹配js脚本中的cron设置定时任务
    for jsname in $(find /monkcoder -name "*.js" | grep -vE "\/backup\/"); do
        jsnamecron="$(cat $jsname | grep -oE "/?/?cron \".*\"" | cut -d\" -f2)"
        test -z "$jsnamecron" || echo "$jsnamecron node /scripts/monkcoder_${jsname##*/} >> /scripts/logs/monkcoder_${jsname##*/}.log 2>&1" >> /scripts/docker/merged_list_file.sh
    done
}

function jddj(){
    # 备份cookie文件
    [[ -f /scripts/jddj/jddj_cookie.js ]] && cp -rf /scripts/jddj/jddj_cookie.js /scripts/backup_jddj_cookie.js
    # clone
    rm -rf /scripts/jddj && git clone https://ghproxy.com/https://github.com/passerby-b/JDDJ /scripts/jddj
    # 下载自定义cookie文件地址,如私密的gist地址,需修改
    jddj_cookiefile="https://ghproxy.com/https://raw.githubusercontent.com/passerby-b/JDDJ/main/jddj_cookie.js"
    curl -so /scripts/jddj/jddj_cookie.js $jddj_cookiefile
    # 下载cookie文件失败时从备份恢复
    test $? -eq 0 || cp -rf /scripts/jddj/backup_jddj_cookie.js /scripts/backup_jddj_cookie.js
    # 获取js文件中cron字段设置定时任务
    for jsname in $(ls /scripts/jddj | grep -E "js$" | tr "\n" " "); do
        jsname_cn="$(grep "cron" /scripts/jddj/$jsname | grep -oE "/?/?tag\=.*" | cut -d"=" -f2)"
        jsname_log="$(echo /scripts/jddj/$jsname | sed 's;^.*/\(.*\)\.js;\1;g')"
        jsnamecron="$(cat /scripts/jddj/$jsname | grep -oE "/?/?cron \".*\"" | cut -d\" -f2)"
        test -z "$jsname_cn" && jsname_cn=$jsname_log
        test -z "$jsnamecron" || echo "# $jsname_cn" >> /scripts/docker/merged_list_file.sh
        test -z "$jsnamecron" || echo "$jsnamecron node /scripts/jddj/$jsname >> /scripts/logs/$jsname_log.log 2>&1" >> /scripts/docker/merged_list_file.sh
    done
}

function didi(){
    # clone
    rm -rf /scripts/didi && git clone https://ghproxy.com/https://github.com/passerby-b/didi_fruit /scripts/didi
    curl -so /scripts/didi/sendNotify.js https://ghproxy.com/https://raw.githubusercontent.com/passerby-b/JDDJ/main/sendNotify.js
    # 获取js文件中cron字段设置定时任务
    echo "10 0,8,12,18 * * * node /scripts/didi/dd_fruit.js >> /scripts/logs/dd_fruit.log 2>&1" >> /scripts/docker/merged_list_file.sh
}

function redrain(){
    rm -rf /longzhuzhu
    rm jd-half-mh.json
    rm jd_half_redrain.js
    rm jd_super_redrain.js
    rm longzhuzhu.boxjs.json
    git clone https://ghproxy.com/https://github.com/nianyuguai/longzhuzhu /longzhuzhu
    # 拷贝脚本
    for jsname in $(find /longzhuzhu/qx -name "*.js"); do cp ${jsname} /scripts/${jsname##*/}; done
    for jsoname in $(find /longzhuzhu/qx -name "*.json"); do cp ${jsoname} /scripts/${jsoname##*/}; done
    echo "30 0-23/1 * * * node /scripts/jd_half_redrain.js >> /scripts/logs/jd_half_redrain.log 2>&1" >> /scripts/docker/merged_list_file.sh
    echo "0 0-23/1 * * * node /scripts/jd_super_redrain.js >> /scripts/logs/jd_super_redrain.log 2>&1" >> /scripts/docker/merged_list_file.sh
}

function custom(){
    rm jd_try.js
    curl -O https://ghproxy.com/https://raw.githubusercontent.com/ZCY01/daily_scripts/main/jd/jd_try.js
    echo "5 10 * * * node /scripts/jd_unsubscribe.js >> /scripts/logs/jd_unsubscribe.log 2>&1" >> /scripts/docker/merged_list_file.sh
    echo "30 10 * * * node /scripts/jd_try.js >> /scripts/logs/jd_try.log 2>&1" >> /scripts/docker/merged_list_file.sh
    rm jd_zoo.js
    curl -O https://ghproxy.com/https://raw.githubusercontent.com/yangtingxiao/QuantumultX/master/scripts/jd/jd_zoo.js
}

function main(){
    # 首次运行时拷贝docker目录下文件
    [[ ! -d /jd_diy ]] && mkdir /jd_diy && cp -rf /scripts/docker/* /jd_diy
    #monkcoder
    #redrain
    jddj
    didi
    custom
    # 拷贝docker目录下文件供下次更新时对比
    cp -rf /scripts/docker/* /jd_diy
}

main