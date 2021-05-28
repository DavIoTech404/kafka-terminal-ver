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

sed '/listeners=PLAINTEXT:\/\/:9092/c\listeners=PLAINTEXT:9092' -i $serverProperties
sed '/#/c\' -i $serverProperties

echo ''
echo "Deseja configurar o servidor com o Endereço IP [pub]Público, [pvt]Privado, [local]localhost ou [man]Configurar um Endereço manualmente?"
read choice

port=$(sh ./broker-all-settings.sh $serverProperties zookeeper-port)

if [ "$choice" = "pub" ]
then
	echo "Encontrando endereço público..."
	echo ''
	publicAddress=$(curl ifconfig.me)
	sed '/zookeeper.connect=/c\zookeeper.connect='$publicAddress':'$port'' -i $serverProperties
	echo "Servidor configurado com endereço Público com sucesso!"
	echo "Seu Endereço Público é: $publicAddress"
fi

if [ "$choice" = "pvt" ]
then
	netinterface=$(ip route | grep default | sed -e "s/^.*dev.//" -e "s/.proto.*//")
	privateAddress=$(ifconfig $netinterface | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
	sed '/zookeeper.connect=/c\zookeeper.connect='$privateAddress':'$port'' -i $serverProperties
	echo "Servidor configurado com endereço Privado com sucesso!"
	echo "Seu Endereço Privado é: $privateAddress"
fi

if [ "$choice" = "local" ]
then
	sed '/zookeeper.connect=/c\zookeeper.connect=localhost:'$port'' -i $serverProperties
	echo "Servidor configurado com localhost com sucesso!"
fi

if [ "$choice" = "man" ]
then
	echo "Qual endereço deve ser atribuido?"
	read address
	sed '/zookeeper.connect=/c\zookeeper.connect='$address':'$port'' -i $serverProperties
	echo "Servidor configurado com o endereço: $address"
fi
