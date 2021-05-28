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

deleteData() {
	serverDir=$(sh ./broker-all-settings.sh $serverProperties log-dir)
	echo ""
	echo "##### [ATENÇÃO] Para que as réplicas sejam ativadas é necessário parar os brokers e deletar todos os seus registros [ATENÇÃO] #####"
	echo ""
	echo "Deseja EXCLUIR os REGISTROS de "[$serverDir]" agora ou manualmente mais tarde? [now] [later]"
	validator=0
	while [ $validator -eq 0 ]
	do
		read rawRes
		res=$(echo $rawRes | awk '{print tolower($0)}')
		case "$res" in
			"now")
				rm -rf $serverDir/*
				echo "Dados excluídos com sucesso."
				validator=1
			;;
			"later")
				validator=1
			;;
			*)
				echo "Operação inválida."
				validator=0
			;;
		esac
	done
}

sed '/listeners=PLAINTEXT:\/\/:9092/c\listeners=PLAINTEXT:9092' -i $serverProperties
sed '/#/c\' -i $serverProperties

validator=0
while [ $validator -eq 0 ]
do
	if [ -z $2 ]
	then
		echo ''
		echo "######################################################"
		echo "## Qual será o novo número de Réplicas por Tópicos? ##"
		echo "######################################################"
	
		read number
	else
		number=$2
	fi
	if [ "$number" -eq "$number" ]
	then	
		pattern=default.replication.factor
		grep -q $pattern $serverProperties
		if [ ! $? -eq 0 ]
		then
			sed '5i\default.replication.factor='$number'' -i $serverProperties
			sed '/offsets.topic.replication.factor=/c\offsets.topic.replication.factor='$number'' -i $serverProperties
			sed '/transaction.state.log.replication.factor=/c\transaction.state.log.replication.factor='$number'' -i $serverProperties
			echo "Configuração concluída, novo Fator de Réplicas: $number"
			deleteData
			validator=1
		else
			sed '/default.replication.factor/c\default.replication.factor='$number'' -i $serverProperties
			sed '/offsets.topic.replication.factor=/c\offsets.topic.replication.factor='$number'' -i $serverProperties
			sed '/transaction.state.log.replication.factor=/c\transaction.state.log.replication.factor='$number'' -i $serverProperties
			echo "Configuração concluída, novo Fator de Réplicas: $number"
			deleteData
			validator=1
		fi
	else
		echo "Número inválido."
		validator=0
	fi
done
