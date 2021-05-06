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

sed '/#listeners=PLAINTEXT:\/\/:9092/c\listeners=PLAINTEXT:9092' -i $serverProperties
sed '/#/c\' -i $serverProperties

validator=0
while [ $validator -eq 0 ]
do
	if [ -z $2 ]
	then
		echo ''
		echo "###################################################"
		echo "# Como deseja configurar o Endereço IP do Broker? #"
		echo "###################################################"
		echo "[pub]Público."
		echo "[pvt]Privado."
		echo "[local]localhost."
		echo "[man]Manualmente."
		echo ''
	
		read choice
	else
		choice=$2
	fi
	
	port=$(sh ./broker-all-settings.sh $serverProperties broker-port)
	
	case "$choice" in
		"pub")
			echo "Encontrando endereço público..."
			echo ''
			publicAddress=$(curl ifconfig.me)
			sed '/listeners=PLAINTEXT:/c\listeners=PLAINTEXT://'$publicAddress':'$port'' -i $serverProperties
			echo "Servidor configurado com endereço Público com sucesso!"
			echo "Seu Endereço Público é: $publicAddress"
			validator=1
			;;
			
		"pvt")
			netinterface=$(ip route | grep default | sed -e "s/^.*dev.//" -e "s/.proto.*//")
			privateAddress=$(ifconfig $netinterface | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | 	grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
			sed '/listeners=PLAINTEXT:/c\listeners=PLAINTEXT://'$privateAddress':'$port'' -i $serverProperties
			echo "Servidor configurado com endereço Privado com sucesso!"
			echo "Seu Endereço Privado é: $privateAddress"
			validator=1
			;;
			
		"local")
			sed '/listeners=PLAINTEXT:/c\listeners=PLAINTEXT://localhost:'$port'' -i $serverProperties
			echo "Servidor configurado com localhost com sucesso!"
			validator=1
			;;
			
		"man")	
			echo "Qual endereço deve ser atribuido?"
			read address
			sed '/listeners=PLAINTEXT:/c\listeners=PLAINTEXT://'$address':'$port'' -i $serverProperties
			echo "Servidor configurado com endereço Privado com sucesso!"
			echo "Configurado com o endereço: $address"
			validator=1
			;;
		*)
			echo "Escolha inválida."
			validator=0
	esac
done
