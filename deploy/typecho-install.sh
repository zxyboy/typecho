

# 下载源码并解压
function download_typecho_and_extract(){
    
  # 如果typecho.zip文件不存在 或 typecho.zip文件大小为0
    if [ ! -f "typecho.zip" ] || [ ! -s "typecho.zip" ]; then
        rm -fr "typecho.zip"
       echo "正在下载Typecho源代码..."
      # 下载Typecho源代码
       curl --request GET -sL \
            --url "$typecho_download_url"\
            --output 'typecho.zip'
       # 解压：
       unzip  -d "$DEPLOYMENT_DIR/php-fpm/typecho" typecho.zip
    fi
}


# 创建部署目录
function mkdir_deployment(){

    mkdir -p "$DEPLOYMENT_DIR";

    # 创建Nginx容器挂在目录
    mkdir -p "$DEPLOYMENT_DIR/nginx/conf" "$DEPLOYMENT_DIR/nginx/logs"

    # 创建MySQL容器挂在目录
    mkdir -p "$DEPLOYMENT_DIR/mysql/data" "$DEPLOYMENT_DIR/mysql/logs" "$DEPLOYMENT_DIR/mysql/conf"

    # 创建PHP-FPM容器挂在目录
    mkdir -p "$DEPLOYMENT_DIR/php-fpm/typecho"
}


# 定义一个函数来安装unzip和curl
function install_unzip_curl() {
    # 获取操作系统类型
    local os_type=$(uname)
    if [ "$os_type" == "Linux" ]; then
        if [ -x "$(command -v apt-get)" ]; then
            sudo apt-get update
            sudo apt-get install -y unzip curl
        elif [ -x "$(command -v yum)" ]; then
            sudo yum install -y unzip curl
        else
            echo "不支持的Linux发行版"
            exit 1
        fi
    elif [ "$os_type" == "Darwin" ]; then
        if [ -x "$(command -v brew)" ]; then
             brew install unzip curl
        else
            echo "未找到Homebrew，请安装Homebrew后再试。"
            exit 1
        fi
    elif [ "$os_type" == "Linux" ] && [ -f "/proc/sys/kernel/osrelease" ]; then
        if [ -x "$(command -v apt-get)" ]; then
            sudo apt-get update
            sudo apt-get install -y unzip curl
        elif [ -x "$(command -v yum)" ]; then
            sudo yum install -y unzip curl
        else
            echo "未找到支持的包管理器。"
            exit 1
        fi
    else
        echo "不支持的操作系统"
        exit 1
    fi
}


#  TODO
function install_docker_and_docker_compose() {
    # 获取操作系统类型
    local os_type=$(uname)
    if [ "$os_type" == "Linux" ]; then
        if [ -x "$(command -v apt-get)" ]; then
            sudo apt-get update
            # 安装docker
            sudo apt-get install -y docker.io
            sudo apt-get install -y
        elif [ -x "$(command -v yum)" ]; then
            sudo yum install -y unzip curl
        else
            echo "不支持的Linux发行版"
            exit 1
        fi
    elif [ "$os_type" == "Darwin" ]; then
        if [ -x "$(command -v brew)" ]; then
             brew install unzip curl
        else
            echo "未找到Homebrew，请安装Homebrew后再试。"
            exit 1
        fi
    elif [ "$os_type" == "Linux" ] && [ -f "/proc/sys/kernel/osrelease" ]; then
        if [ -x "$(command -v apt-get)" ]; then
            sudo apt-get update
            sudo apt-get install -y unzip curl
        elif [ -x "$(command -v yum)" ]; then
            sudo yum install -y unzip curl
        else
            echo "未找到支持的包管理器。"
            exit 1
        fi
    else
        echo "不支持的操作系统"
        exit 1
    fi
}


# 创建docker-compose.yaml文件
function create_docker_compose() {

# 如果 docker-compose.yaml文件不存在
if [ ! -f "$DEPLOYMENT_DIR/docker-compose.yaml" ]; then
# 创建docker-compose.yaml文件
cat << EOF > "$DEPLOYMENT_DIR/docker-compose.yaml"
version: "3.1"

services:
  nginx:
    image: nginx:1.25.2-alpine3.18
    ports:
      - "80:80"
      - "443:443"
    restart: always
    volumes:
      - ./php-fpm/typecho:/usr/share/nginx/html
      - ./nginx/conf:/etc/nginx/conf.d
      - ./nginx/logs:/var/log/nginx
    depends_on:
      - php-fpm
    networks:
      - typecho

  php-fpm:
    image: joyqi/typecho:nightly-php7.3-fpm-alpine
    restart: always
    volumes:
      #
      - ./php-fpm/typecho:/app
    environment:
      - TZ=Asia/Shanghai
    depends_on:
      - mysql
    networks:
      - typecho

  mysql:
    image: mysql:8.1.0
    restart: always
    command: --default-authentication-plugin=mysql_native_password
    environment:
      - TZ=Asia/Shanghai
      - MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
      - MYSQL_DATABASE=typecho_blog
    volumes:
      - ./mysql/data:/var/lib/mysql
      - ./mysql/logs:/var/log/mysql
      - ./mysql/conf:/etc/mysql/conf.d
    networks:
      - typecho
networks:
  typecho:
EOF
fi
}


#  随机生成10位数密码， 在(Linux, MacOS, Windows）中都可以使用，要求：数字、大小写字母、$, _
function generate_password(){
    local os_type=$(uname)
     local password=""
     local password_length=10
    if [ "$os_type" == "Linux" ]; then
        password=$(cat /dev/urandom | tr -dc 'A-Za-z0-9$_' | head -c $password_length)
    elif [ "$os_type" == "Darwin" ]; then
        password=$(export LC_CTYPE=C && cat /dev/urandom | tr -dc 'A-Za-z0-9$_' |  fold -w  $password_length | head -n 1 )
    elif [ "$os_type" == "Linux" ] && [ -f "/proc/sys/kernel/osrelease" ]; then
         password=$(cat /dev/urandom | tr -dc 'A-Za-z0-9$_' | head -c  $password_length)
    else
        echo "不支持的操作系统"
        exit 1
    fi
    echo "$password"
}

# 判断docker中是否包含typecho网络
function is_typecho_network_exists(){
    # 获取typecho网络数量
    local typecho_network_count=$(docker network ls | grep typecho | wc -l)
    # 如果typecho网络数量大于0
    if [ $typecho_network_count -gt 0 ]; then
        return 1
    else
        return 0
    fi
}

# 判断docker中是否包含typecho容器
function is_typecho_container_exists(){
    # 获取typecho容器数量
    local typecho_container_count=$(docker ps -a | grep typecho | wc -l)
    # 如果typecho容器数量大于0
    if [ $typecho_container_count -gt 0 ]; then
        # 返回0
        return 1
    else
        # 返回1
        return 0
    fi
}


# 是否安装成功安装过次脚本
function is_install_success(){
    # docker中是否包含typecho容器  && docker中是否包含typecho网络
    if is_typecho_container_exists && is_typecho_network_exists; then
        return 1
    else
        return 0
    fi
}

# 检查证书文件
function check_ssl_and_config_ssl_cert() {
    # 获取当前目录下以key结尾的文件
    key_suffix_files=$(ls  | grep -E "key$")
    for file in $key_suffix_files; do
        echo "$file"
        # 去掉文件后缀
        file_name=${file%.*}
        pem_file_name="$file_name.pem"
      # 判断目录下是否包含 *.key 和*.pem 文件
        if [ ! -f "$pem_file_name" ]; then
            echo " $file 和 $pem_file_name 文件不存在，请将证书文件放到当前目录下。"
            exit 1
        else
            if [ ! -d "$cert_dir" ]; then
                # 创建$cert_dir目录
                mkdir -p "$cert_dir"
            fi
            # $cert_dir目录下不包含 $file 或 $pem_file_nam 文件，则拷贝
            if [ ! -f "$cert_dir/$file" ]; then
                # 拷贝证书文件到$cert_dir目录下
                cp  -f "$file" "$cert_dir"
            fi

            if  [ ! -f "$cert_dir/$pem_file_name" ]; then
                # 拷贝证书文件到$cert_dir目录下
                cp -f "$pem_file_name" "$cert_dir"
            fi

            # 生成nginx配置文件
            cat << EOF > "$DEPLOYMENT_DIR/nginx/conf/$file_name.conf"
                server {
                    #SSL 访问端口号为 443
                    listen 443 ssl;
                    #填写绑定证书的域名
                    server_name www.$file_name $file_name;
                    #证书文件名称
                    ssl_certificate /etc/nginx/conf.d/cert/$pem_file_name;
                    #私钥文件名称
                    ssl_certificate_key /etc/nginx/conf.d/cert/$file;
                    ssl_session_cache shared:SSL:1m;
                    ssl_session_timeout 5m;
                    #自定义设置使用的TLS协议的类型以及加密套件（以下为配置示例，请您自行评估是否需要配置）
                    #TLS协议版本越高，HTTPS通信的安全性越高，但是相较于低版本TLS协议，高版本TLS协议对浏览器的兼容性较差。
                    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
                    ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;
                    #表示优先使用服务端加密套件。默认开启
                    ssl_prefer_server_ciphers on;
                    error_log  /var/log/nginx/error.log;
                    access_log /var/log/nginx/access.log;
                    #charset koi8-r;
                    #access_log  /var/log/nginx/host.access.log  main;

                    location / {
                        root   /usr/share/nginx/html;
                        index  index.html index.htm index.php;
                        try_files \$uri \$uri/ /index.php\$is_args\$args;
                    }

                    #error_page  404              /404.html;

                    # redirect server error pages to the static page /50x.html
                    #
                    error_page   500 502 503 504  /50x.html;
                    location = /50x.html {
                        root   /usr/share/nginx/html;
                    }

                    # proxy the PHP scripts to Apache listening on 127.0.0.1:80
                    #
                    #location ~ \.php\$ {
                    #    proxy_pass   http://127.0.0.1;
                    #}

                    # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
                    #
                    location ~ .*\.php(\/.*)*\$ {
                       root           /usr/share/nginx/html;
                        # 注意： 这里需要指定php-fpm主机
                       fastcgi_pass   php-fpm:9000;
                       fastcgi_index  index.php;
                       include        fastcgi_params;
                        # 注意： 这里指定的是php-fpm容器的路径
                       fastcgi_param  SCRIPT_FILENAME /app\$fastcgi_script_name;

                    }

                    # deny access to .htaccess files, if Apache's document root
                    # concurs with nginx's one
                    #
                    location ~ /\.ht {
                       deny  all;
                    }
                }
                server {
                    listen 80;
                    #填写证书绑定的域名
                    server_name www.$file_name $pem_file_name;
                    #将所有HTTP请求通过rewrite指令重定向到HTTPS。
                    rewrite ^(.*)\$ https://\$host\$1;
                    return 301 https://\$host\$request_uri;
                    location / {
                        index index.html index.htm;
                    }
                }

EOF

        fi
    done

}


# 如果已经安装过
if is_install_success; then
    echo "已经安装过Typecho博客系统，如果需要重新安装，请先卸载。"
    exit 1
fi

# 部署目录
DEPLOYMENT_DIR="$HOME/typecho";
# 目标证书目录
cert_dir="$DEPLOYMENT_DIR/nginx/conf/cert"
# typecho源码下载链接
typecho_download_url="https://objects.githubusercontent.com/github-production-release-asset-2e65be/11467667/8ff092d2-a53f-4dbe-a1ae-2c0b6b62bab2?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20231019%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20231019T150317Z&X-Amz-Expires=300&X-Amz-Signature=0c9d20e178d041b2ce6cda1025d8b9c70d5740b06a0eea175bdc3de56466d65a&X-Amz-SignedHeaders=host&actor_id=0&key_id=0&repo_id=11467667&response-content-disposition=attachment%3B%20filename%3Dtypecho.zip&response-content-type=application%2Foctet-stream"
# MySQL ROOT用户密码，
MYSQL_ROOT_PASSWORD=$(generate_password)

# 创建部署需要挂载的目录
mkdir_deployment

# 安装curl、unzip命令
install_unzip_curl

# 下载typecho源码并解析
download_typecho_and_extract

# 创建docker-compose.yaml文件
create_docker_compose

# 查看本目录下文件中以 key 或者 pem结尾的文件，拷贝文件和生成nginx配置文件
check_ssl_and_config_ssl_cert

echo "开始部署Typecho博客系统..."
# 使用docker-compose启动容器
docker-compose -f "$DEPLOYMENT_DIR/docker-compose.yaml"  up -d

# 如果上一条命令执行失败
if [ $? -ne 0 ]; then
    echo "部署失败，请检查错误信息。"
    exit 1
else
    # 数据库地址
    echo "数据库地址：mysql , 注意： 安装typecho的时候数据库地址应该填写： mysql， 而不是填写：localhost 或者 127.0.0.1"  >> typecho_install_info.log
    # 数据库名称
    echo "数据库名称：typecho_blog"  >> typecho_install_info.log
    # 数据库用户名
    echo "数据库用户名：root"  >> typecho_install_info.log
    # 数据库密码
    echo "数据库密码：$MYSQL_ROOT_PASSWORD"  >> typecho_install_info.log
    # 数据库端口
    echo "数据库端口：3306"  >> typecho_install_info.log
    # 数据库版本
    echo "数据库版本：8.1.0"  >> typecho_install_info.log
    # PHP版本
    echo "PHP版本：7.3"  >> typecho_install_info.log
    # Nginx版本
    echo "Nginx版本：1.25.2"  >> typecho_install_info.log
    # typecho安装目录
    echo "typecho安装目录：$DEPLOYMENT_DIR"  >> typecho_install_info.log
    # Nginx容器挂载目录
    echo "Nginx容器挂载目录：$DEPLOYMENT_DIR/nginx"  >> typecho_install_info.log
    # Nginx配置文件挂载目录
    echo "Nginx配置文件挂载目录：$DEPLOYMENT_DIR/nginx/conf"  >> typecho_install_info.log
    # Nginx日志挂载目录
    echo "Nginx日志挂载目录：$DEPLOYMENT_DIR/nginx/logs"  >> typecho_install_info.log
    # PHP-FPM容器挂载目录
    echo "PHP-FPM容器挂载目录：$DEPLOYMENT_DIR/php-fpm"  >> typecho_install_info.log
    # Typecho容器挂载目录
    echo "Typecho容器挂载目录：$DEPLOYMENT_DIR/php-fpm/typecho"  >> typecho_install_info.log
    # MySQL容器挂载目录
    echo "MySQL容器挂载目录：$DEPLOYMENT_DIR/mysql"  >> typecho_install_info.log
    # MySQL数据挂载目录
    echo "MySQL数据挂载目录：$DEPLOYMENT_DIR/mysql/data"  >> typecho_install_info.log
    # MySQL日志挂载目录
    echo "MySQL日志挂载目录：$DEPLOYMENT_DIR/mysql/logs"  >> typecho_install_info.log
    # MySQL配置文件挂载目录
    echo "MySQL配置文件挂载目录：$DEPLOYMENT_DIR/mysql/conf"  >> typecho_install_info.log
    # Typecho版本
    echo "Typecho版本：1.2-17.10.30"  >> typecho_install_info.log

    # 获取本地外部地址
    EXTERNAL_IP=$(curl -s https://ipinfo.io/ip)
    # 获取本机内部地址
    INTERNAL_IP="127.0.0.1"
    # 输出提示信息
    echo "部署完成，请访问外网链接 http://${EXTERNAL_IP} 进行安装。 或者 访问内网链接 http://${INTERNAL_IP} 进行安装" >> typecho_install_info.log
    cat typecho_install_info.log
    mv typecho_install_info.log "$DEPLOYMENT_DIR/typecho_install_info.log"
    # 打印安装日志所在目录
    echo "安装日志所在目录：$DEPLOYMENT_DIR/typecho_install_info.log"
fi


