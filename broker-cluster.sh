if [ ! -f ./config/default-settings.json ]
then
	echo "Alterando o diretório de trabalho..."
	echo "[DICA]: para evitar lentidões e possíveis bugs na execução dos serviços, entre no diretório de trabalho do script."
	currentScriptDir=$(find $HOME -name index-kafka.sh | grep -v Trash | head -n 1 | sed 's/'index-kafka.sh'//')
	cd $currentScriptDir
fi
sh ./config/dataVerifier.sh
kafkaPath=$(cat ./config/default-settings.json | jq '.kafkaPath' | sed 's/"//g')

jsonCluster="./config/broker-cluster.json"
brokerCluster=$(cat $jsonCluster)
tab='  '

echo "########################################################################"
echo "##### Obtendo informações da configuração de Clusters existente... #####"
echo "########################################################################"

firstSettings() {
	serverPath=$(find $kafkaPath -name  server.properties | head -n 1)
	id=0
	port=$(sh broker-all-settings.sh $serverPath broker-port)
	dir=$(sh broker-all-settings.sh $serverPath log-dir)
	
	echo "{" > $jsonCluster
	echo "$tab\"path\": \"$serverPath\"," >> $jsonCluster
	echo "$tab\"id\": \"$id\"," >> $jsonCluster
	echo "$tab\"port\": \"$port\"," >> $jsonCluster
	echo "$tab\"dir\": \"$dir\"" >> $jsonCluster
	echo "}" >> $jsonCluster
	brokerCluster=$(cat $jsonCluster)
}

if [ -z "$brokerCluster" ]
then
	firstSettings
fi



for row in $(echo "${brokerCluster}" | jq -r '. | @base64'); do
	id=$(echo ${row} | base64 --decode | jq -r '.id')
	echo "================================================================="
	echo "Broker: "$id
	printf "Local: "
	echo ${row} | base64 --decode | jq -r '.path'
	printf "Porta: "
	echo ${row} | base64 --decode | jq -r '.port'
	printf "Diretório: "
	echo ${row} | base64 --decode | jq -r '.dir'
	echo "================================================================="
	id=$(($id + 1))
done



check() 
{
verify=$(echo "${brokerCluster}" | jq -r '. | select(.'\"$1\"'=='\"$2\"') | .'\"$1\"'')
if [ ! -z "$verify" ]
then
	validator=0;
	echo "$1: $2 já está em uso, tente novamente."
else
	validator=1;
fi
}

null()
{
	if [ -z $1 ]
	then
		echo "Valores nulos não são permitidos, tente novamente."
		validator=0
	fi
}



echo ""
echo "Prosseguir com a criação de outro broker para o cluster [p]."
echo "Excluir a configuração existente [delete]."
echo ""
echo "## ATENÇÃO todos os brokers e seus arquivos serão excluídos permanentemente caso opte pela deleção, com exceção do broker inicial que apenas terá seus dados atualizados. ##"
validator=0
while [ $validator -eq 0 ]
do
	read choice
	if [ "$(echo $choice | awk '{print tolower($0)}')" = "delete" ]
	then
		for row in $(echo "${brokerCluster}" | jq -r '. | @base64'); do
			id=$(echo ${row} | base64 --decode | jq -r '.id')
			serverPath=$(echo ${row} | base64 --decode | jq -r '.path')
			dir=$(echo ${row} | base64 --decode | jq -r '.dir')
			
			if [ ! $id -eq 0 ]
			then
				rm -rf $serverPath $dir
			fi
		done
		firstSettings
		echo "Exclusão concluída."
		exit
	elif [ "$(echo $choice | awk '{print tolower($0)}')" = "p" ]
	then
		validator=1
	else
		echo "Resposta inválida, tente novamente..."
		validator=0
	fi
done



json=$(echo "${brokerCluster}" | jq -r '. | @base64')
serverPath=$(echo $json | base64 --decode --ignore-garbage | jq -r '.path' | head -n 1)

echo "* O broker irá possuir o id: $id. Prosseguir com este id? [y] [n] *"
validator=0
while [ $validator -eq 0 ]
do
	read choice
	if [ "$(echo $choice | awk '{print tolower($0)}')" = "n" ]
	then
		echo "Qual será o id do broker?"
		while [ $validator -eq 0 ]
		do
			read id
			if [ $id -eq $id ]
			then
				check id $id
				null $id
			else
				echo "Este id não é um número válido, tente novamente."
				validator=0
			fi
		done
	elif [ ! "$(echo $choice | awk '{print tolower($0)}')" = "y" ]
	then
		echo "Resposta inválida, tente novamente..."
		validator=0
	else
		check id $id
		null $id
	fi
done



echo ""
echo "* Qual será a porta utilizada pelo broker? *"
validator=0
while [ $validator -eq 0 ]
do
	read port
	if [ $port -eq $port ]
	then
		check port $port
		null $port
	else
		echo "Esta porta não é um número válido, tente novamente."
		validator=0
	fi
done



dir=$(echo $json | base64 --decode --ignore-garbage | jq -r '.dir' | head -n 1)
dir=$dir$id
echo ""
echo "* O diretório de armazenagem de dados será: [$dir]. Prosseguir com este diretório? [y] [n] *"
validator=0
while [ $validator -eq 0 ]
do
	read choice
	if [ "$(echo $choice | awk '{print tolower($0)}')" = "n" ]
	then
		echo "Qual será o diretório do broker?"
		while [ $validator -eq 0 ]
		do
			read dir
			if [ -d $dir ]
			then
				check dir $dir
				null $dir
			else
				echo "[$dir] não é um diretório válido, tente novamente."
				validator=0
			fi
		done
	elif [ ! "$(echo $choice | awk '{print tolower($0)}')" = "y" ]
	then
		echo "Resposta inválida, tente novamente..."
		validator=0
	else
		check dir $dir
		null $dir
	fi
done



serverPath=$serverPath$id

echo ""
echo "##### [ REVISÃO ] #####"
echo "PATH: "$serverPath
echo "ID: "$id
echo "PORTA: "$port
echo "DIRÉTÓRIO DE DADOS: "$dir
echo ""
echo "[ ATENÇÃO ] As outras configurações dos Brokers serão copiadas do broker de id 0, mas ainda será possível alterá-las individualmente pelo item [29] do menu."
echo ""

validator=0
while [ $validator -eq 0 ]
do
	echo "##### Deseja finalizar a criação deste Broker? [finish] [cancel] #####"
	read choice
	if [ "$(echo $choice | awk '{print tolower($0)}')" = "finish" ]
	then
		validator=1
		echo "{" >> $jsonCluster
		echo "$tab\"path\": \"$serverPath\"," >> $jsonCluster
		echo "$tab\"id\": \"$id\"," >> $jsonCluster
		echo "$tab\"port\": \"$port\"," >> $jsonCluster
		echo "$tab\"dir\": \"$dir\"" >> $jsonCluster
		echo "}" >> $jsonCluster
		echo "Broker adicionado ao JSON broker-cluster.json com sucesso!"
		echo "Executando construtor de brokers..."
		sh broker-cluster-assembler.sh
	elif [ "$(echo $choice | awk '{print tolower($0)}')" = "cancel" ]
	then
		echo "Cancelando deste broker criação"
		validator=1
	else
		echo "Operação inválida."
		validator=0
	fi
done
