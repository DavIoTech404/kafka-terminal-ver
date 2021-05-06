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

dirConfig()
{
	slashCheck=$(echo -n $dir | tail -c 1)
	if [ "$slashCheck" = "/" ]
	then
		sed '/log.dirs=/c\log.dirs='$dir'' -i $serverProperties
	else
		sed '/log.dirs=/c\log.dirs='$dir'/' -i $serverProperties
	fi
}

if [ ! -z $1 ]
then
	serverProperties=$1
fi

sed '/listeners=PLAINTEXT:\/\/:9092/c\listeners=PLAINTEXT:9092' -i $serverProperties
sed '/#/c\' -i $serverProperties

validator=0
while [ $validator -eq 0 ]
do
	if [ -z $2 ]
	then
		echo ''
		echo "########################################"
		echo "## Qual será o novo diretório padrão? ##"
		echo "########################################"
		read dir
	else
		dir=$2
	fi


	if [ -z $dir ]
	then
		echo "Operação inválida."
		validator=0
	else
		if [ -d $dir ]
		then
			dirConfig
			echo "Configuração concluída, novo diretório: $dir"
			validator=1
		else
			mkdir $dir
			if [ $? -eq 0 ]
			then
				dirConfig
				echo "Configuração concluída, novo diretório: $dir"
				validator=1
			fi
		fi
	fi
done
