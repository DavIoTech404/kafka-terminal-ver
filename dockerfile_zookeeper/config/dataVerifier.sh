kafkaPath=$(cat ./config/default-settings.json | jq '.kafkaPath' | sed 's/"//g')
concat="bin/kafka-server-start.sh"
if [ ! -f $kafkaPath$concat ]
then
	echo "Houve uma falha ao tentar localizar os arquivos do Kafka, procurando os arquivos novamente e atualizando a base de dados do sistema."
	kafkaPath=$(find $HOME -name kafka-server-start.sh | grep -v Trash | head -n 1 | sed 's/bin\/kafka-server-start.sh//')
	echo 
	sed '/\"kafkaPath\":/c\\"kafkaPath\": \"'$kafkaPath'\",' -i ./config/default-settings.json
	echo "Dados atualizados com sucesso."
fi
