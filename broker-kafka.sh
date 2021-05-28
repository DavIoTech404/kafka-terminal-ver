if [ ! -f ./config/default-settings.json ]
then
	echo "Alterando o diretório de trabalho..."
	echo "[DICA]: para evitar lentidões e possíveis bugs na execução dos serviços, entre no diretório de trabalho do script."
	currentScriptDir=$(find $HOME -name index-kafka.sh | grep -v Trash | head -n 1 | sed 's/'index-kafka.sh'//')
	cd $currentScriptDir
fi
sh ./config/dataVerifier.sh
kafkaPath=$(cat ./config/default-settings.json | jq '.kafkaPath' | sed 's/"//g')
prometheusPath="$(pwd)/prometheus"
serverProperties=$(find $kafkaPath  -name  server.properties | grep -v Trash | head -n 1)
echo "Inicializando broker..."


if [ ! -z $1 ]
then
	serverProperties=$1
fi

cd $kafkaPath

JAVA_HOME="/usr/lib/jvm/java-1.11.0-openjdk-amd64" KAFKA_OPTS="-javaagent:$prometheusPath/jmx_prometheus_javaagent-0.15.0.jar=8089:$prometheusPath/kafka-0-8-2.yml" bin/kafka-server-start.sh $serverProperties
echo "Não foi possível conectar-se ao zookeeper... tentando novamente."

JAVA_HOME="/usr/lib/jvm/java-1.11.0-openjdk-amd64" KAFKA_OPTS="-javaagent:$prometheusPath/jmx_prometheus_javaagent-0.15.0.jar=8089:$prometheusPath/kafka-0-8-2.yml" bin/kafka-server-start.sh $serverProperties
echo "Não foi possível conectar-se ao zookeeper... tentando pela última vez..."

JAVA_HOME="/usr/lib/jvm/java-1.11.0-openjdk-amd64" KAFKA_OPTS="-javaagent:$prometheusPath/jmx_prometheus_javaagent-0.15.0.jar=8089:$prometheusPath/kafka-0-8-2.yml" bin/kafka-server-start.sh $serverProperties
