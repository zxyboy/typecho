# 卸载typecho

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



# 如果未安装
if ! is_install_success; then
    echo "typecho未安装，无需卸载"
    exit 1
fi

# 部署目录
DEPLOYMENT_DIR="$HOME/typecho";


# 停止容器
echo "正在停止容器...."
docker-compose -f "$DEPLOYMENT_DIR/docker-compose.yaml" down
echo "容器已停止...."

# 删除目录
echo "正在删除Nginx目录...."
rm -rf "$DEPLOYMENT_DIR/nginx"
echo "Nginx目录已删除...."

echo "正在删除PHP-FPM目录...."
rm -rf "$DEPLOYMENT_DIR/php-fpm"
echo "PHP-FPM目录已删除...."

# 询问用户使用删除MySQL目录
read -p "是否删除MySQL目录(y/n)，删除后数据将不可恢复: " is_delete_mysql_dir
# 如果用户输入y或者Y
if [ "$is_delete_mysql_dir" == "y" ] || [ "$is_delete_mysql_dir" == "Y" ]; then
    # 删除MySQL目录
    echo "正在删除MySQL目录...."
    rm -rf "$DEPLOYMENT_DIR/mysql"
    echo "MySQL目录已删除...."
fi

# 删除docker-compose.yaml文件
echo "正在删除docker-compose.yaml文件...."
rm -rf "$DEPLOYMENT_DIR/docker-compose.yaml"
echo "docker-compose.yaml文件已删除...."

# 删除typecho.zip
echo "正在删除typecho.zip文件...."
rm -rf "$DEPLOYMENT_DIR/typecho.zip"
echo "typecho.zip文件已删除...."

# 删除 typecho_install_info.log
echo "正在删除typecho_install_info.log文件...."
rm -rf "$DEPLOYMENT_DIR/typecho_install_info.log"
echo "typecho_install_info.log文件已删除...."

# 卸载完成
echo "卸载完成"
