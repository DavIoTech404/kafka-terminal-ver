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

execute() {
sh $1 $serverProperties
}

repeat() {
	echo "Deseja configurar algum outro fator? [y] [n]"
	validator=2
	while [ $validator -eq 2 ]
	do
		read rawRes
		res=$(echo $rawRes | awk '{print tolower($0)}')
		case "$res" in
			"y")
				echo "Qual fator do broker será alterado?"
				validator=0
			;;
			"n")
				validator=1
			;;
			*)
				echo "Operação inválida."
				validator=2
			;;
		esac
	done
}


sh ./broker-all-settings.sh $serverProperties

echo "Qual fator do broker será alterado?"
echo "exemplo: broker-id"

validator=0
while [ $validator -eq 0 ]
do
	read rawChoice
	choice=$(echo $rawChoice | awk '{print tolower($0)}')
	case "$choice" in
		"broker-id")
			execute "server-id.sh"
			repeat
		;;
		
		"replication-factor")
			execute "default-replication-factor.sh"
			repeat
		;;
		
		"broker-address")
			execute "server-address.sh"
			repeat
		;;
		
		"broker-port")
			execute "server-port.sh"
			repeat
		;;
		
		"log-dir")
			execute "default-data-dir.sh"
			repeat
		;;
		
		"partition-number")
			execute "default-partition-number.sh"
			repeat
		;;
		
		"log-retention-time")
			execute "log-retention.sh"
			repeat
		;;
		
		"zookeeper-address")
			execute "zookeeper-address.sh"
			repeat
		;;
		
		"zookeeper-port")
			execute "zookeeper-port.sh"
			repeat
		;;
		
		*)
			echo "Fator inválido."
			validator=0;
		;;
	esac
done
