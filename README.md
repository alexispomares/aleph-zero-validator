# Aleph Zero | Running a Validator Node
 
A simple setup to have an [Aleph Zero](https://alephzero.org) decentralized validator node running in under an hour.

For in-depth general instructions please refer to the [technical documentation](https://docs.alephzero.org/aleph-zero/stake/validators). The official docs leave margin for the dev to choose a number of specifics for their own setup, which is precisely what we do in this GitHub repo.

This setup has already been used to run 2 separate nodes for 2+ years with 100% uptime.

![Warp CLI Screenshot](/img/running-node-warp-cli.jpeg)

## Server Specifications

The official recommended Aleph Zero specs for each node are summarized in the image below. I have been running a [Bare Metal OVH server](https://eco.ovhcloud.com) for each of my 2 nodes with the following specs:
- `OS`: Ubuntu Server 22.04 LTS
- `CPU`: Intel Xeon E3-1230v6 - 4c/8t - 3.5 GHz/3.9 GHz
- `RAM`: 32 GB ECC 2133 MHz
- `Storage`: 2×450 GB SSD NVMe
- `Bandwidth`: 250 Mbps (outgoing & incoming)
- `Price`: $50 USD/month

![Azero Node Specs](/img/node-specs.jpeg)

Before you secure your bare metal server, remember that in order to run a node you need to bond at least [25,000 AZERO tokens](https://docs.alephzero.org/aleph-zero/stake/validators) for a minimum of 2 weeks. This is a security measure to prevent sybil attacks (w/ thousands of fake identities) and ensure that a real vested interest in the network is required to validate blocks and transactions. If you want to buy AZERO, they have a [summary of the available options here](https://docs.alephzero.org/aleph-zero/explore/where-to-buy-azero).

## Logging Into The Server

_💡 Pro Tip: If you use Mac, I highly recommend using [Warp](https://warp.dev) for your CLI. It's an amazing dev experience, and it has a really convenient feature called [Workflows](https://docs.warp.dev/features/warp-drive/workflows) which can save your bash commands, even parametrizing certain parts as variables — super useful if you know you'll be frequently reusing the same / similar commands! This feature is what you can see in the left panel of the [first screenshot](/img/running-node-warp-cli.png) in this README._

Once you have your OVH server up and running, you will want to log into it using [SSH](https://arjunaravind.in/blog/learning-and-using-ssh). First, follow [the official guide](https://help.ovhcloud.com/csm/en-dedicated-servers-creating-ssh-keys) to create an SSH key pair and add it to your OVH server. I recommend also setting up a passphrase for added security in case someone had access to your machine.

Once you have your SSH key pair set up, you can log into your server using the following command (I recommend saving it as a [Workflows](https://docs.warp.dev/features/warp-drive/workflows), including the parametrized `{{ipAddress}}` variable with a default value):

```bash
ssh ubuntu@{{ipAddress}}
```

Or alternatively, if you wanted to run more than one node at the same time (say for testnet and mainnet, or for different use cases), you can use the following:

```bash
if [ "{{network}}" = "mainnet" ]; then
    ssh ubuntu@{{mainnetIpAddress}}
elif [ "{{network}}" = "testnet" ]; then
    ssh ubuntu@{{testnetIpAddress}}
fi
```

If you previously set up a passphrase, you will be prompted to introduce it now. Once done, you're in! You should see a subshell with your username in this format: `ubuntu@your-server-name`.

## Setting Up The Node

The server should be ready to go with the default Ubuntu 22.04 installation. If you want to make sure everything is up to date, you can run the following command:

```bash
sudo apt update && sudo apt upgrade -y
```

Now, let's get our Aleph Zero node up and running! First you will need to install `docker` on your fresh Linux machine using the following command:

```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install the Docker packages:
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

I also recommend that you add your user to the `docker` group so that using `docker` doesn’t require `sudo` (admin) access:

```bash
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
```

To verify that Docker installed correctly and you can run it without `sudo`, this should show a confirmation message:

```bash
docker run hello-world
```

Next, you will want to clone the 'Aleph Node Runner' repo.

```bash
git clone https://github.com/Cardinal-Cryptography/aleph-node-runner
cd aleph-node-runner
```

Once inside the `aleph-node-runner` folder, run:

```bash
./run_node.sh -n {{yourNodeName}}  --ip {{yourPublicIp}} --mainnet

docker logs -f {{yourNodeName}} --tail 20
```

The first time you run this, it will take quite some time before you actually get the node running, as it needs to download a database snapshot of ~100GB. Your logs should eventually look something like this:

```bash
2022-07-04 12:32:09 〽️ Prometheus exporter started at 0.0.0.0:9615    
2022-07-04 12:32:09 Running session 4013.    
2022-07-04 12:32:10 🔍 Discovered new external address for our node: /ip4/195.150.192.250/tcp/30333/p2p/12D3KooWFGUSW3DMq92JSoGKkBM5WTNJ4bFiJ88PDCX6ttnXadQU    
2022-07-04 12:32:11 ✅ no migration for System    
2022-07-04 12:32:11 ✅ no migration for RandomnessCollectiveFlip    
2022-07-04 12:32:11 ✅ no migration for Scheduler    
2022-07-04 12:32:11 ⚠️ Aleph declares internal migrations (which *might* execute). On-chain `StorageVersion(2)` vs current storage version `StorageVersion(2)`     
2022-07-04 12:32:11 Running migration from STORAGE_VERSION 0 to 1 for pallet elections    
2022-07-04 12:32:11 ✅ no migration for Treasury    
2022-07-04 12:32:11 ✅ no migration for Vesting    
2022-07-04 12:32:11 ✅ no migration for Utility    
2022-07-04 12:32:14 Running session 4014.    
2022-07-04 12:32:14 ⚙️  Syncing, target=#4662784 (16 peers), best: #3618503 (0xe8a9…47c8), finalized #3612599 (0xf40d…de62), ⬇ 927.5kiB/s ⬆ 16.5kiB/s    
2022-07-04 12:32:18 Running session 4015.    
2022-07-04 12:32:19 ⚙️  Syncing 1668.2 bps, target=#4662789 (16 peers), best: #3626844 (0x0ee0…03b6), finalized #3613499 (0x03fd…669d), ⬇ 793.5kiB/s ⬆ 6.1kiB/s    
2022-07-04 12:32:22 Running session 4016. 
```

And that's all! Your node is now live, connected to the Aleph Zero network, and able to communicate with other nodes and receive blocks. 🥳

## Managing The Node

From time to time, you will want to log into your server and update the software that your node is running (typically after an official announcement from the Aleph Zero Foundation).

Firstly, you can check the status of your node at any time by running:

```bash
docker ps
docker logs -f {{yourNodeName}} --tail 20
```

If you want to update your node, you need to first stop it quickly, pull the latest changes from the `aleph-node-runner` repo, and run the node again. Here's a script that does just that:

```bash
docker stop {{yourNodeName}}
    
cd ~/aleph-node-runner
git pull

./run_node.sh -n {{yourNodeName}} --ip {{yourPublicIp}} --mainnet
cd ..
```

## Staying Updated

Lastly, validating transactions in a blockchain is a low-maintenance effort, but it still requires keeping an eye out for updates (or incidents) from time to time.

I recommend setting up a Telegram alert with [Azero.live](https://docs.alephzero.org/aleph-zero/account/telegram-notifications) so that their bot notifies you if your node would ever stop producing blocks for any reason. The process is really quick (< 3 minutes), simple, and free!

You should also follow the team's updates for validators either on [Discord or Telegram](https://alephzero.org/community), as that is where they announce any updates that may relate to your node. In my experience, a software update is necessary every ~6 months or so.

---

And that's it! You are now an active part of the decentralized Aleph Zero network, helping to secure the blockchain and validate transactions. Hopefully this will be a rewarding experience not just in monetary terms, but also by knowing your node is contributing to creating a (hopefully!) better global financial system. :)