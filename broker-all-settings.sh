if [ ! -f ./config/default-settings.json ]
then
	currentScriptDir=$(find $HOME -name index-kafka.sh | grep -v Trash | head -n 1 | sed 's/'index-kafka.sh'//')
	cd $currentScriptDir
fi
kafkaPath=$(cat ./config/default-settings.json | jq '.kafkaPath' | sed 's/"//g')

serverProperties=$(find $kafkaPath  -name  server.properties | head -n 1)

if [ ! -z "$1" ]
then
	serverProperties=$1
fi

sed '/listeners=PLAINTEXT:\/\/:9092/c\listeners=PLAINTEXT:9092' -i $serverProperties
sed '/#/c\' -i $serverProperties

if [ -z "$2" ]
then
	echo "Reunindo informações sobre o broker..."
	brokerId=$(cat $serverProperties | grep 'broker.id=' | awk -Fbroker.id= '{ print $2 }')
	replicationFactor=$(cat $serverProperties | grep 'default.replication.factor=' | awk -Fdefault.replication.factor= '{ print $2 }')
	brokerAddress=$(cat $serverProperties | grep 'listeners=PLAINTEXT://' | awk -Flisteners=PLAINTEXT:// '{ print $2 }'| awk -F: '{ print $1 }')
	brokerPort=$(cat $serverProperties | grep 'listeners=PLAINTEXT:'| awk -F:// '{ print $2 }' | awk -F: 	'{ print $2 }')
	if [ -z $brokerPort ]
	then
		brokerPort=$(cat $serverProperties | grep 'listeners=PLAINTEXT:'| awk -FPLAINTEXT: '{ print $2 }')
	fi
	dir=$(cat $serverProperties | grep 'log.dirs=' | awk -Flog.dirs= '{ print $2 }')
	partitionNumber=$(cat $serverProperties | grep 'num.partitions=' | awk -Fnum.partitions= '{ print $2 }')
	logRetentionTime=$(cat $serverProperties | grep 'log.retention.hours=' | awk -Flog.retention.hours= '{ print $2 }')
	zookeeperAddress=$(cat $serverProperties | grep 'zookeeper.connect=' | awk -Fzookeeper.connect= '{ print $2 }' | awk -F: '{ print $1 }')
	zookeeperPort=$(cat $serverProperties | grep 'zookeeper.connect=' | awk -F: '{ print $2 }')

	echo "============================================================"
	echo "[broker-id]: "$brokerId
	echo "[replication-factor]: "$replicationFactor
	echo "[broker-address]: "$brokerAddress
	echo "[broker-port]: "$brokerPort
	echo "[log-dir]: "$dir
	echo "[partition-number]: "$partitionNumber
	echo "[log-retention-time]: "$logRetentionTime
	echo "[zookeeper-address]: "$zookeeperAddress
	echo "[zookeeper-port]: "$zookeeperPort
	echo "============================================================"
else
	case "$2" in
		"broker-id")
			cat $serverProperties | grep 'broker.id=' | awk -Fbroker.id= '{ print $2 }'
		;;
		
		"replication-factor")
			cat $serverProperties | grep 'default.replication.factor=' | awk -Fdefault.replication.factor= '{ print $2 }'
		;;
		
		"broker-address")
			cat $serverProperties | grep 'listeners=PLAINTEXT://' | awk -Flisteners=PLAINTEXT:// '{ print $2 }'| awk -F: '{ print $1 }'
		;;
		
		"broker-port")
			brokerPort=$(cat $serverProperties | grep 'listeners=PLAINTEXT:'| awk -F:// '{ print $2 }' | awk -F: 	'{ print $2 }')
			if [ -z $brokerPort ]
			then
				brokerPort=$(cat $serverProperties | grep 'listeners=PLAINTEXT:'| awk -FPLAINTEXT: '{ print $2 }')
			fi
			echo $brokerPort
		;;
		
		"log-dir")
			cat $serverProperties | grep 'log.dirs=' | awk -Flog.dirs= '{ print $2 }'
		;;
		
		"partition-number")
			cat $serverProperties | grep 'num.partitions=' | awk -Fnum.partitions= '{ print $2 }'
		;;
		
		"log-retention-time")
			cat $serverProperties | grep 'log.retention.hours=' | awk -Flog.retention.hours= '{ print $2 }'
		;;
		
		"zookeeper-address")
			cat $serverProperties | grep 'zookeeper.connect=' | awk -Fzookeeper.connect= '{ print $2 }' | awk -F: '{ print $1 }'
		;;
		
		"zookeeper-port")
			cat $serverProperties | grep 'zookeeper.connect=' | awk -F: '{ print $2 }'
		;;
		
		*)
			echo "Parâmetro inválido."
		;;
	esac
fi
