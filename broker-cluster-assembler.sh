if [ ! -f ./config/default-settings.json ]
then
	echo "Alterando o diretório de trabalho..."
	echo "[DICA]: para evitar lentidões e possíveis bugs na execução dos serviços, entre no diretório de trabalho do script."
	currentScriptDir=$(find $HOME -name index-kafka.sh | grep -v Trash | head -n 1 | sed 's/'index-kafka.sh'//')
	cd $currentScriptDir
fi
sh ./config/dataVerifier.sh

brokerCluster=$(cat ./config/broker-cluster.json)
json=$(echo "${brokerCluster}" | jq -r '. | @base64')
mainServerPath=$(echo $json | base64 --decode --ignore-garbage | jq -r '.path' | head -n 1)


configBroker()
{
	echo "==================================================================================================="
	echo "Configurando o broker: "$id
	sh ./server-id.sh $serverPath $id
	sh ./server-port.sh $serverPath $port
	sh ./default-data-dir.sh $serverPath $dir
	echo "Broker: "$id", criado e configurado com sucesso!"
	echo "==================================================================================================="
}

for broker in $(echo "${brokerCluster}" | jq -r '. | @base64'); do
	serverPath=$(echo ${broker} | base64 --decode | jq -r '.path')
	id=$(echo ${broker} | base64 --decode | jq -r '.id')
	port=$(echo ${broker} | base64 --decode | jq -r '.port')
	dir=$(echo ${broker} | base64 --decode | jq -r '.dir')
	
	if [ ! "$serverPath" = "$mainServerPath" ]
	then
		if [ ! -z "$serverPath" ]
		then
			if [ -e "$serverPath" ]
			then
				echo "Editando broker existente..."
				configBroker
			else
				echo "Criando broker..."
				cp $mainServerPath $serverPath
				configBroker
			fi
		else
			echo "#####################################################################"
			echo "### Todos os brokers disponíveis já foram criados e configurados. ###"
			echo "#####################################################################"
		fi
	fi
done
