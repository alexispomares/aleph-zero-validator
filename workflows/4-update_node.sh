docker stop {{yourNodeName}}
    
cd ~/aleph-node-runner
git pull

./run_node.sh -n {{yourNodeName}} --ip {{yourPublicIp}} --mainnet