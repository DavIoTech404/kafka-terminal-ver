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

address=$(sh ./broker-all-settings.sh $serverProperties broker-address)
port=$(sh ./broker-all-settings.sh $serverProperties broker-port)

json=$(cat ./config/topic-config.json)

cd $kafkaPath
for row in $(echo "${json}" | jq -r '.[] | @base64'); do
    currentRow() {
     echo ${row} | base64 --decode | jq -r ${1}
    }
    topic=$(currentRow '.topic')

    echo "Criando o tópico: $topic"
    bin/kafka-topics.sh --create --topic $topic --bootstrap-server $address:$port
done

    echo "Fim da criação dos tópicos."
