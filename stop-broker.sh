kill -9 $(ps -ef | grep java | grep "server.properties" | grep -v grep | awk '{print $2}')
echo "Broker parado com sucesso!"
