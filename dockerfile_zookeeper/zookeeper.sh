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
echo "Inicializando zookeeper..."
cd $kafkaPath
EXTRA_ARGS="-javaagent:$prometheusPath/jmx_prometheus_javaagent-0.15.0.jar=8080:$prometheusPath/zookeeper.yaml" bin/zookeeper-server-start.sh config/zookeeper.properties

echo "Erro ao inicializar o zookeeper."
