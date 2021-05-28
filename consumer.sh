if [ ! -f ./config/default-settings.json ]
then
	echo "Alterando o diretório de trabalho..."
	echo "[DICA]: para evitar lentidões e possíveis bugs na execução dos serviços, entre no diretório de trabalho do script."
	currentScriptDir=$(find $HOME -name index-kafka.sh | grep -v Trash | head -n 1 | sed 's/'index-kafka.sh'//')
	cd $currentScriptDir
fi
sh ./config/dataVerifier.sh
kafkaPath=$(cat ./config/default-settings.json | jq '.kafkaPath' | sed 's/"//g')

serverProperties=$(find $kafkaPath  -name  server.properties | head -n 1)

if [ ! -z $1 ]
then
	serverProperties=$1
fi

address=$(sh ./broker-all-settings.sh $serverProperties broker-address)
port=$(sh ./broker-all-settings.sh $serverProperties broker-port)

consumer=$(jq -r '.[].consumer' ./config/service-config.json)
cd $kafkaPath
    
echo "Criando consumer do tópico: $consumer"
bin/kafka-console-consumer.sh --topic $consumer --from-beginning --bootstrap-server $address:$port
