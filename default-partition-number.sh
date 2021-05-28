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

echo ''
echo "#######################################################"
echo "Qual será o novo número padrão de partições por tópico?"
read number


if [ "$number" -eq "$number" ]
	then
	sed '/num.partitions=/c\num.partitions='$number'' -i $serverProperties
	echo "Configuração concluída, novo número padrão de partições: $number"
fi
