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

cd $kafkaPath

echo "Criando um Consumer manualmente."

echo "Tópico: [none]data"
read topic
echo "EndereçoIP: [none]$address"
read manAddress
echo "Porta: [none]$port"
read manPort
bin/kafka-console-consumer.sh --topic ${topic:="data"} --from-beginning --bootstrap-server  ${manAddress:=$address}:${manPort:=$port}

echo "Não foi possível estabelecer conexão com o Broker."
