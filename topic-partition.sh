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

address=$(sh ./broker-all-settings.sh $serverProperties zookeeper-address)
port=$(sh ./broker-all-settings.sh $serverProperties zookeeper-port)

echo ""
echo "##########################################################"
echo "# Qual tópico deve ter seu número de partições alterado? #"
echo "##########################################################"
read topico
echo "Novo número de partições para $topico:"
read partitionNumber

if [ "$partitionNumber" -eq "$partitionNumber" ]
then
	echo "Alterando o número de partições do tópico $topico para $partitionNumber."
	cd $kafkaPath
	bin/kafka-topics.sh --alter --zookeeper $address:$port  --topic $topico --partitions $partitionNumber
	echo "Alteração concluída."
fi