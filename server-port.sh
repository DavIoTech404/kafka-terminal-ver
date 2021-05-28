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

if [ -z $2 ]
then	
	echo ''
	echo "##################################"
	echo "## Qual será a Porta utilizada? ##"
	echo "##################################"
	read port
else
	port=$2
fi

address=$(sh ./broker-all-settings.sh $serverProperties broker-address)

if [ "$port" -eq "$port" ]
then
	sed '/listeners=PLAINTEXT:/c\listeners=PLAINTEXT://'$address':'$port'' -i $serverProperties
	echo "Configuração concluída, nova porta: $port"
fi
