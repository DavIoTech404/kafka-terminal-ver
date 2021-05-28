#!/bin/bash

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

sed '/#listeners=PLAINTEXT:\/\/:9092/c\listeners=PLAINTEXT:9092' -i $serverProperties
sed '/#/c\' -i $serverProperties

	if [ ! -z $ZOOKEEPER_ONLY ]
	then
		sh ./zookeeper.sh
	else
		if [ ! -z $ZOOKEEPER ]
		then
			sed '/zookeeper.connect=/c\zookeeper.connect='$ZOOKEEPER'' -i $serverProperties
		else
			zooPort=$(sh ./broker-all-settings.sh $serverProperties zookeeper-port)
			sed '/zookeeper.connect=/c\zookeeper.connect=192.168.1.245:'$zooPort'' -i $serverProperties
		fi
		if [ ! -z $LISTENER ]
		then
			listenerPort=$(echo $LISTENER | awk -F: '{ print $2 }')
			netinterface=$(ip route | grep default | sed -e "s/^.*dev.//" -e "s/.proto.*//")
			privateAddress=$(ifconfig $netinterface | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | 	grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
			sed "/listeners=PLAINTEXT:/c\advertised.listeners=PLAINTEXT://$LISTENER" -i $serverProperties
		else
			netinterface=$(ip route | grep default | sed -e "s/^.*dev.//" -e "s/.proto.*//")
			privateAddress=$(/sbin/ip route|awk '/default/ { print $3 }')
			echo "Listener: $privateAddress:9092"
			sed '/listeners=PLAINTEXT:/c\listeners=PLAINTEXT://'$privateAddress':9092' -i $serverProperties
		fi
		if [ ! -z $LISTENER_PORT ]
		then
			address=$(sh ./broker-all-settings.sh $serverProperties broker-address)
			sed '/listeners=PLAINTEXT:/c\listeners=PLAINTEXT://'$address':'$LISTENER_PORT'' -i $serverProperties
			echo "New listener port: $LISTENER_PORT"
		fi
		if [ ! -z $LISTENER_ADDRESS ]
		then
			port=$(sh ./broker-all-settings.sh $serverProperties broker-address)
			sed '/listeners=PLAINTEXT:/c\listeners=PLAINTEXT://'$LISTENER_ADDRESS':'$LISTENER_PORT'' -i $serverProperties
			echo "Listener address: $LISTENER_ADDRESS"
		fi
		if [ ! -z $BROKER_ID ]
		then
			sed '/broker.id=/c\broker.id='$BROKER_ID'' -i $serverProperties
		else
			sed '/broker.id=/c\broker.id=1' -i $serverProperties
		fi
		if [ ! -z $REPLICATION ]
		then
			sed '5i\default.replication.factor='$REPLICATION'' -i $serverProperties
			sed '/offsets.topic.replication.factor=/c\offsets.topic.replication.factor='$REPLICATION'' -i $serverProperties
			sed '/transaction.state.log.replication.factor=/c\transaction.state.log.replication.factor='$REPLICATION'' -i $serverProperties
		fi
	fi

sh ./broker-kafka.sh
