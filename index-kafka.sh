if [ ! -f ./config/default-settings.json ]
then
	echo "Alterando o diretório de trabalho..."
	echo "[DICA]: para evitar lentidões e possíveis bugs na execução dos serviços, entre no diretório de trabalho do script."
	currentScriptDir=$(find $HOME -name index-kafka.sh | grep -v Trash | head -n 1 | sed 's/'index-kafka.sh'//')
	cd $currentScriptDir
fi
sh ./config/dataVerifier.sh
kafkaPath=$(cat ./config/default-settings.json | jq '.kafkaPath' | sed 's/"//g')

json=$(cat ./config/menu-config.json)
rerun=$(echo sh index-kafka.sh)

    echo "##########################################################"
	echo "###############   O QUE DESEJA EXECUTAR?   ###############"
    echo "##########################################################"

for row in $(echo "${json}" | jq -r '.[] | @base64'); do
    currentRow() {
     echo ${row} | base64 --decode | jq -r ${1}
    }
    key=$(currentRow '.key')
    description=$(currentRow '.name')
    
    echo "[$key]$description "
done

    echo "##########################################################"
    echo ""
	read keyPressed

if [ "$keyPressed" = "exit" ]
then
    exit
fi

rawIndex=$(echo "${json}" | jq -r '.[] | select(.key=='\"$keyPressed\"') | .execute')

if [ -z "$keyPressed" ] | [ "$rawIndex" = "null" ] | [ -z "$rawIndex" ]
then
	echo "Operação inválida"
	echo ""
else
	command=$(echo $(echo $rawIndex | sed -r 's/sh //g'))
	if [ -z "${rawIndex##*sh*}" ]
	then
		echo "#### Executando $command #####"
		echo ""
		sh $command
	else
		echo "#### Executando $command #####"
		echo ""
		$command
	fi
fi
#executa menu novamente
$rerun
