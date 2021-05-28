if [ ! -f ./config/default-settings.json ]
then
	echo "Alterando o diretório de trabalho..."
	echo "[DICA]: para evitar lentidões e possíveis bugs na execução dos serviços, entre no diretório de trabalho do script."
	currentScriptDir=$(find $HOME -name index-kafka.sh | grep -v Trash | head -n 1 | sed 's/'index-kafka.sh'//')
	cd $currentScriptDir
fi
sh ./config/dataVerifier.sh

brokerCluster=$(cat ./config/broker-cluster.json)

for broker in $(echo "${brokerCluster}" | jq -r '. | @base64'); do
	serverPath=$(echo ${broker} | base64 --decode | jq -r '.path')
	sh ./broker-all-settings.sh $serverPath
done

repeat() {
	echo "Deseja alterar a configuração de mais algum broker? [y] [n]"
	while [ $validator -eq 0 ]
	do
		read rawRes
		res=$(echo $rawRes | awk '{print tolower($0)}')
		case "$res" in
			"y")
				echo "Qual o Id do broker que será alterado?"
				validator=0
			;;
			"n")
				validator=1
			;;
			*)
				echo "Operação inválida."
				validator=0
			;;
		esac
	done
}

echo "Qual o Id do broker que será alterado?"
validator=0
while [ $validator -eq 0 ]
do
	read id
	if [ ! -z "$id" ] | [ "$id" -eq "$id" ]
	then
		serverPath=$(echo "${brokerCluster}" | jq -r '. | select(.id=='\"$id\"') | .path')
		if [ ! -z "$serverPath" ]
		then
			sh ./broker-quick-settings.sh $serverPath
			repeat
		else
			echo "Broker não foi encontrado..."
			validator=0
		fi
	else
		echo "Id inválido."
		validator=0
	fi
done
