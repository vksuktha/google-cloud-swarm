source "./options.sh"

echo "Creating Manager(s)"
echo $MANAGER_SECRET_KEY

for i in `seq 1 $NUM_MANAGERS`
do

	docker-machine create  \
	--driver amazonec2 \
	--amazonec2-zone $MANAGER_ZONE \
	--amazonec2-region $MANAGER_REGION $PREFIX-manager-$i 
done


echo "Creating Worker"

for i in `seq 1 $NUM_WORKERS`
do
	
	docker-machine create  \
	-d amazonec2 \
	--amazonec2-zone $WORKER_ZONE \
	--amazonec2-region $WORKER_REGION $PREFIX-worker-$i
	
done

echo "Waiting fof Instances to start"

wait

echo "Instance(s) Created"

SWARM_MANAGER_INTERNAL_IP=$(docker-machine ip $PREFIX-manager-1)

echo $SWARM_MANAGER_INTERNAL_IP

echo "Creating Swarm"

eval $(docker-machine env $PREFIX-manager-1)

docker swarm init

echo "Adding Manager(s)"

for i in `seq 2 $NUM_MANAGERS`
do 
	eval $(docker-machine env $PREFIX-manager-$i) && \
	docker swarm join $SWARM_MANAGER_INTERNAL_IP:2377 &
done

echo "Adding Worker(s)"

for i in `seq 1 $NUM_WORKERS`
do
	eval $(docker-machine env $PREFIX-worker-$i) && \
	docker swarm join $SWARM_MANAGER_INTERNAL_IP:2377 &
done
wait

echo "Swarm Created !"
echo "eval $(docker-machine env $PREFIX-manager-1)"