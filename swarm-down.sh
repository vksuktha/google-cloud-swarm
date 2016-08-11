# include options.sh for all the variables
source ./options.sh

echo "Deleting Manager(s)"

for i in `seq 1 $NUM_MANAGERS`
do
    docker-machine rm -f $PREFIX-manager-$i &
done

echo "Deleting Workers(s)"

for i in `seq 1 $NUM_WORKERS`
do
    docker-machine rm -f $PREFIX-worker-$i &
done

wait
echo "Cluster Deleted"