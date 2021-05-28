kill -9 $(ps -ef | grep java | grep "zookeeper.properties" | grep -v grep | awk '{print $2}')
echo "Zookeeper parado com sucesso!"
