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

sed '/#listeners=PLAINTEXT:\/\/:9092/c\listeners=PLAINTEXT:9092' -i $serverProperties
sed '/#/c\' -i $serverProperties

if [ $2 -z ]
then
	echo ''
	echo "########################################"
	echo "## Qual será a Porta a ser utilizada? ##"
	echo "########################################"
	read port
else
	port=$2
fi

address=$(sh ./broker-all-settings.sh $serverProperties zookeeper-address)

if [ "$port" -eq "$port" ]
then
	sed '/zookeeper.connect=/c\zookeeper.connect='$address':'$port'' -i $serverProperties
	echo "Configuração concluída, nova porta: $port"
fi
