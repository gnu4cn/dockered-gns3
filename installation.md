#在Docker容器中使用GNS3来进行Cisco网络仿真
#Cisco Network Emulation with GNS3 in a Docker container

GNS3是一款有趣软件，它将不同的开放源代码软件粘和起来，实现对由思科路由器（使用真实思科固件）、思科交换机（使用IOU，思科IOS on Unix）、思科ASA（adaptive security appliance, 下一代防火墙）以及其它任何可以运行在Qemu或者VirtualBox仿真软件上的设备所组成的计算机网络的仿真。

GNS3 is a fantastic piece of software, it glues together different open source software and allows to emulate a network that includes Cisco routers (using real Cisco firmware), Cisco switches (using IOU, Cisco IOS on Unix), Cisco ASA and any other devices that can run on Qemu or Virtual Box emulator. 

它允许将虚拟网络连接到物理网络，从仿真网络到互联网的访问以及从互联网访问仿真网络都是可以的。GNS3可以在Windows、Mac OSX以及Linux上运行，但运行在Linux上是最好的，因为要用上IOU，如果不是在Linux上，你就需要一个运行于VirtualBox上的Linux虚拟机。

It also allows to connect the virtual network to the physical network, it is possible to access Internet in the emulated world and vice-versa. GNS3 is available on Windows, Mac OSX and on Linux, but it shines on Linux because, to use IOU, if you are not on Linux you need a Linux virtual machine running on VirtualBox. 

又因为GNS3粘和了许多正处于变动中的部件，所以要将所有东西都安装好并让它们无缝的一起工作起来，就成为了一件棘手的事情，为此我创建了一个已安装好所有东西、功能完整且可立即使用的Docker镜像，运行于Linux上（或是在Windows或Mac OSX上的Linux虚拟机中）。

But, because GNS3 glues together many moving parts, it can be troublesome to install everything and to have everything working seamlessly, for this reason i created a Docker image with everything installed, functioning and ready to be used on Linux (or in a Linux virtual machine running in Windows or Mac OSX). 

Docker 是另一款有趣软件，与 CoreOS 和比如 Google Kubernetes 一样的云计算基础项目一道，是目前正在到来的云计算革命的构筑物。

Docker is another fantastic piece of software that, together with CoreOS and other cloud orchestration projects, like Google's Kubernetes, is one of the building blocks for the incoming Cloud Revolution. 

Docker容器（或者Docker镜像）与虚拟机有一些相似之处，但它们是在一个经由Cgroups以及命名空间隔离(namespace isolation)两种技术得到的，从而实现资源限制（对CPU和RAM的使用），以及与宿主机的其它进程隔离，Docker容器内部不可见这些宿主机的进程，的“chrooted”环境中，与宿主机使用同一个Linux内核。Docker容器的巨大优势在于其毫秒级的启动速度，而不是虚拟机的数十秒，同时由于诸多容器都是共享同一内核，而不必模拟整个的系统，所以它们在主机资源的使用上是更为高效的。在宿主机上你会看到Docker容器中的进程与宿主机普通进程是一样的。

Docker containers (or Docker images) have similarities with virtual machines, but they run on same Linux kernel as the host, in a "chrooted" environment using Cgroups and namespace isolation to provide resource limitation (on cpu and or RAM usage) and isolation from the other host processes that are invisible inside the Docker container. The huge advantage of Docker containers against virtual machines is that they spin-up in milliseconds instead of tens of seconds and, because they share same kernel, don't have to simulate the entire operating system, so they are much more efficient in terms of host resource usage. On the host you see the processe(s) running in a docker container as normal processes. 

Docker容器的另一重要特性是在它们停止后，任何东西都不会保存下来，所以在它们重启时，就如同你在启动一个全新的镜像一样。如你需要留存数据，你必须显式地在Dockerfile中声明永久卷（一些文件夹），或者在启动该Docker镜像时以-v参数形式显式挂载宿主机的某个文件夹到docker镜像上去。在我们的用例中，我们会显式地将用户整个主目录挂载到docker镜像的同样目录上去。

Another important feature of docker containers is that when they stop nothing is saved so that when they restart it is as if you are starting a new fresh image. If you need persistence you have to explicitly declare persistent volumes (folders) on the Dockerfile or you have to explicitly mount a folder, on the host, on a folder, in the docker image, when you start the docker image (-v option); in our case we explicitly mount the user's entire home directory inside same directory in the docker image.

##Docker容器的构建
##Building the Docker Container

我之所以将该容器称为gns3-large，是因为它实在是很大块头的，它包含了用于构建那些该镜像中的软件所需要的所有东西。其对应的Dockerfile在gns3-large的GitHub代码仓库上有，该文件包含了实现以下目的的指令：

I called the container gns3-large, because it is quite fat, it contains everything needed to build some software included in the image. The Docker file is available on the GitHub repository for the gns3-large project and contains instructions to

从Docker Registry官方的最新版Ubuntu(14.04)基础上建立出该镜像

build the image starting from the latest version of Ubuntu (14.04) officially available on the Docker Registry

安装GNS3及有关软件所需的那些软件

install software required by GNS3 and related software 

为实现从GNS3内部抓取和分析封包而安装Wireshark

install Wireshark for packet capture and analysis from inside GNS3

编译并安装Dynamips(GNS3用到的模拟引擎)

compile and install Dynamips (the simulation engine used by GNS3)

安装gns3-gui以及gns3-server，它们是GNS3的两个部件

install gns3-gui and gns3-server, the two components of GNS3

编译并安装VPCS，它是一类PC模拟器，所模拟出的计算机仅具备基本的网络测试功能，如dhcp客户端、ping等

compile and install VPCS, a sort of pc simulator that implements basic network testing functions like dhcp client, ping etc.

编译并安装iouyap, 它是在GNS3中得以执行IOU的接口

compile and install iouyap, it is needed to interface the IOU executable with GNS3

安装QEMU，一个类似VirtualBox的仿真软件

install QEMU, an emulator similar to VirtualBox

安装Gnome连接管理器及gcmconf脚本

install Gnome Connection Manager and the gcmconf script

将startup.sh设置为在容器启动时可执行

set startup.sh as the executable that runs when the container starts

该docker容器可通过mybuild脚本来构建，或者：

The docker container can be built using the mybuild script or:

$ sudo docker build -t="digiampietro/gns3-large" .

你也可以直接从Docker Registry上拉下该镜像：

or the image can be pulled from the Docker Registry with:

$ docker pull digiampietro/gns3-large

这两种方式都需要在你的Linux系统中事先安装Docker。

in both cases you need Docker already installed on your Linux system.

##GNS3和容器网络通信的一些问题
##Networking GNS3 and container

一个docker容器有一个虚拟网络接口eth0，并由docker从172.17.0.0/16网络中随机选择了一个ip地址分配给它，同时该接口已经管线连接（piped）到宿主机的一个对应接口上，该接口通常有着“vethb1ed276”这样的名字。而在宿主机上，与其它容器所属的类似接口一起，都在网桥docker0上进行桥接，网桥docker0的ip地址是172.17.42.1/16。

A docker container has a virtual interface, eth0, with an ip assigned to it randomly chosen by docker from the network 172.17.0.0/16, this interface is "piped" to a corresponding interface on the host with a name similar to vethb1ed276; on the host this interface, together with similar interfaces of other docking containers, are bridged together on the docker0 bridge, that has the ip address 172.17.42.1/16. 

这样的配置允许每个容器都能与宿主机及其它容器实现通信。而为实现与外部世界的网络通信，docker干了下面两件事情：

This configuration allows each container to talk to the host and to the other containers. To allow networking to the outside world docker does two things:

在容器里，它添加了一条到宿主机ip地址172.17.42.1的默认路由

on the container it adds a default route to the host ip address of 172.17.42.1

在宿主机上往iptables里添加了一条NAT规则：

on the host it adds a NAT rule to iptables:

你会注意到 Docker 服务器创建了一条 masquerade 规则，以便让容器连接外部世界的 IP 地址:

You can see that the Docker server creates a masquerade rule that let containers connect to IP addresses in the outside world:

<pre lang="sh">
$ sudo iptables -t nat -L -n
...
Chain POSTROUTING (policy ACCEPT)
target      prot    opt   source          destination         
MASQUERADE  all     –     172.17.0.0/16   0.0.0.0/0
...
</pre>

在docker网站上有更多关于Docker网络配置的资料。

More details on Docker Network Configuration on the docker site. 

在我们的用例中，我既想要从仿真的GNS3网络内部到达外部世界，又要从外部世界抵达到仿真的网络，特别要从宿主机能够使用浏览器和ASDM Launcher上来配置仿真出的思科ASA设备。为此我不希望仿真网络是经由NAT连接上来的。

In our case I want to be able to reach the outside world from inside the emulated GNS3 network, but I also want to be able to reach the emulated network from the outside world, especially from the host: I want, for example, be able to use my browser and ASDM Launcher to configure the emulated Cisco ASA device. For this reason I don't want that the emulated network is NATted. 

为将仿真网络接连至外部世界，GNS3提供了云符号（Cloud symbol）：在其一侧有一个标准接口，通过该接口可以连接上一台路由器，而另一侧就可以接到某个形如eth0这样的物理设备上；但如真要连接到eth0的话，gns3必须以root方式运行；我是不想以root方式运行gns3的（文件访问权限和所属关系问题是主要的原因），为此我在容器中创建了一个归运行gns3的那个用户所有的tap0接口。网络结构如下图所示。

To connect the emulated network to the outside world GNS3 provides the Cloud symbol: on one side it has a standard interface that you can connect to a router, on the other side it can be attached to a physical device like eth0; but to attach it to eth0 gns3 must be run as root; I don't want to run gns3 as root (mainly because of file access rights and ownership issues), for this reason I created a tap0 interface, inside the container, owned by the user running gns3. The picture below shows the network diagram:







##启动该docker容器
##Starting the docker container
此docker容器通常通过myrun.sh脚本来启动，可以修改这个脚本中的一些设置而满足不同需求，在gns3-large的github仓库上可以下载到这个脚本。

The docker container is normally started using the script myrun.sh , that can be personalized to change settings, available on the gns3­large github repository. 

为简化在Docker容器和宿主机之间的数据共享，我们做了以下设定：

To simplify sharing of data between the Docker container and the host what happens is:

在docker容器启动的过程中，与当前用户有着相同用户名及userid的用户会在容器中创建出来，其口令为”docker”。这将使得文件的共享十分容易

during the startup of the docker container a user, with same username and userid of current user, is added to the container, but with the password of docker. This allows easy sharing of files

以-v选项的方式，当前用户的整个主目录被挂载到容器中，从而实现gns3的运行能够取得主目录的完全访问，免除文件访问权限和所属关系的问题

with the -v option the entire current user's home directory is "mounted" inside the container, this allows to run gns3 with full access to user's home directory without any issues related to file access rights and file ownership

在myrun.sh脚本中使用到了许多可以定制的环境变量，该脚本如下所示：

The myrun.sh uses many environment variables that can be personalized, this script is included here:

<pre lang="sh">
#!/bin/sh
export GDISPLAY=unix/$DISPLAY
# forward X11 display to the host machine
export GUSERNAME=`id -u -n`
# current user's username
export GUID=`id -u`
# current user's user id
export GGROUP=`id -g -n`
# current user's primary group name
export GGID=`id -g`
# current user's primary group id
export GHOME=$HOME
# current user's home directory
export GSHELL=$SHELL
# current user's shell
#
# to connect the emulated network to the external world
# we use a tap0 interface inside the docker container
# connected to the GNS3 emulated network through
# a GNS3 Cloud device attached to the tap0 interface
#
export GTAPIP=10.123.1.1
# the tap0 IP address
export GTAPMASK=255.255.255.0
# the tap0 IP netmask
export GTAPNATENABLE=0
# enable NAT on tap0 outgoing traffic
# (if 1 GROUTE2GNS3 must be 0)
export GNS3NETWORK=10.123.0.0
# IP network used inside the GNS3 emulated
# network
export GNS3NETMASK=255.255.0.0 # IP netmask used inside the GNS3 emulated
# network
export GROUTE2GNS3=1
# enable routing from the container eth0 to
# the emulated network
sudo docker run -h gns3-large
\
-v /tmp/.X11-unix:/tmp/.X11-unix \
-v $HOME:$HOME
\
-e DISPLAY=$GDISPLAY
\
-e GUSERNAME=$GUSERNAME
\
-e GUID=$GUID
\
-e GGROUP=$GGROUP
\
-e GGID=$GGID
\
-e GHOME=$HOME
\
-e GSHELL=$SHELL
\
-e GTAPIP=$GTAPIP
\
-e GTAPMASK=$GTAPMASK
\
-e GTAPNATENABLE=$GTAPNATENABLE \
-e GNS3NETWORK=$GNS3NETWORK
\
-e GNS3NETMASK=$GNS3NETMASK
\
-e GROUTE2GNS3=$GROUTE2GNS3
\
--privileged
\
-it digiampietro/gns3-large
</pre>

此脚本运行digiampietro/gns3-large容器，需要注意的一下重要的地方：

This script runs the digiampietro/gns3-large container, the important things to note are:

/tmp/.X11-unix文件夹以-v选项的方式从宿主机挂载到容器，同时将环境变量DISPLAY设置为unix/$DISPLAY，以允许容器在宿主机的显示屏上显示出窗口；

the folder /tmp/.X11-unix is "mounted" from the host to the container (option ­v) and, together with the environment variable DISPLAY set to unix/$DISPLAY , allows the container to display windows in the host display;

整个的用户主目录（也就是环境变量HOME）都被以同样的方式挂载到容器中（-v 选项）；

the entire user's home directory (environment variable HOME ) is mounted on the container at the same position (option -v);

下列环境变量是从宿主机传递到容器中的，它们将会为容器启动时执行的startup.sh脚本用到：

the following environment variables are passed from the host to the container, they will be used by the startup.sh script that will be the script executed at startup by the container:

GUSERNAME, GUID, GGROUP, GGID, GHOME, GSHELL 这些环境变量包含了当前用户的用户名、user id、主用户组名称、住用户组id、主目录以及shell；它们用被startup.sh脚本用于在容器中创建一个对宿主机系统当前用户完整复制的用户；

GUSERNAME, GUID, GGROUP, GGID, GHOME, GSHELL they contain the current user's username, user id, primary group name, primary group id, home directory and shell; they will be used by the startup.sh script to create a user in the container that is a replica of current user in the host system;

GTAPIP, GTAPMASK 这两个环境变量包含了容器的tap0接口的ＩＰ地址和子网掩码，默认为10.123.1.1/255.255.255.0，如上面的图表所示；

GTAPIP, GTAPMASK contains IP address and netmask of the container's tap0 interface, by default this address is 10.123.1.1 with netmask 255.255.255.0 as shown in the network diagram above;

GTAPNATENABLE环境变量在设置为1时，其告诉启动脚本（startup.sh）在eth0上启用NAT，此模式下如没有其它设置，仿真网络可以达到外部世界和互联网；但外部世界和宿主机系统是无法抵达到仿真网络的，因为仿真网络处于一个NAT后面（在上面的图表中可以看出来）；如果设置了这个变量，就不能设置 GROUTE2GNS3变量了；

GTAPNATENABLE if set to 1 this variable tells the startup script to enable NAT on the eth0 interface, in this way, without any other setup, the emulated network will be able to reach the external world and the internet; but the external world, and the host system, will not be able to reach the emulated network because it will be behind a NAT (see the above network diagram); If this variable is set, GROUTE2GNS3 must be unset;

GNS3NETWORK, GNS3NETMASK 两个变量包含了在仿真网络中要用到的网络地址及其子网掩码，默认是
10.123.0.0/255.255.0.0。该信息仅在变量 GTAPNATENABLE为0且 GROUTE2GNS3为1时，为启动脚本startup.sh用到；

GNS3NETWORK, GNS3NETMASK they contain the network address and netmask that will be used in the emulated network, by default these values are 10.123.0.0 and 255.255.0.0 . This information will be used by the startup.sh script only if GTAPNATENABLE is 0 and GROUTE2GNS3 is 1 .

GROUTE2GNS3当该变量设置为1时，告诉startup.sh脚本建立一个到仿真网络的路由；以这种方式连接仿真网络时，就不是通过NAT方式，仿真网络可以访问到宿主机和外部世界，同时从宿主机和外部世界可以访问到仿真网络，前提是不但要如上图中那样在宿主机中添加一些路由， 还要在ADSL路由器中添加路由。在宿主机上添加路由较为容易，只需执行一个命令：

sudo ./hostroute2gns3(这个hostroute2gns3脚本在gns3-large的git代码仓库上有)；同时你也必须在ADSL路由器上为网络$GNS3NETWORK/$GNS3NETMASK添加一条路由，将Linux宿主机的IP地址（该Linux宿主机必须要有固定的IP地址或者做DHCP地址保留以实现其总是能得到相同的IP地址）作为默认网关；

GROUTE2GNS3 if set to 1 tells the startup.sh script to setup a route to the emulated network; in this way the emulated network will not be "natted" and can reach and be reached by the host and by the external world, but routes must be added on the host and, with reference to the above network diagram, on the ADSL router. Adding the route on the host is easy, justo do a sudo ./hostroute2gns3 (the hostroute2gns3 is available on the gns3-large git repository); You have to add a route for the network $GNS3NETWORK/$GNS3NETMASK on the ADSL router also, giving it, as default gateway, the IP address of the linux host (the linux host must have an IP fixed address or a DHCP reservation that gives it always the same IP address);

--privileged选项运行容器以root权限运行，在创建tap0设备时需要这样运行；

--privileged option allows the container to run with root privileges, this is needed to create the tap0 device;

-it digiampietro/gns3-large 选项表示以一个终端方式启动该命名容器；

-it digiampietro/gns3-large starts the named container with a controlling terminal;

在myrun.sh脚本执行完毕后，gns3-large容器便启动了起来，它会执行Dockerfile中指定的startup.sh脚本：

After executing the myrun.sh the gns3-large container is started and it executes the startup.sh script, as specified in the Dockerfile:

<pre lang="sh">
#!/bin/sh
#
# add current user and user's primary group
#groupadd -g $GGID $GGROUP
useradd -u $GUID -s $GSHELL -c $GUSERNAME -g $GGID -M -d $GHOME $GUSERNAME
usermod -a -G sudo $GUSERNAME
echo $GUSERNAME:docker | chpasswd
#
# generate IOU License
#
if [ -e $GHOME/gns3-misc/keygen.py ]
then
cp $GHOME/gns3-misc/keygen.py /src/misc/
cd /src/misc
./keygen.py | egrep "license|`hostname`" > iourc.txt
else
echo "IOU License File generator keygen.py not found"
echo "please put keygen.py in"
echo "$GHOME/gns3-misc/keygen.py"
fi
#
# create the tap device owned by current user
# assign it an IP address, enable IP routing and NAT
#
echo "-------------------------------------------------------------------"
echo "tap0 has address $GTAPIP netmask $GTAPMASK"
echo "if yuou use the cloud symbol to connect to the physical network"
echo "use an address on the same subnet, and, on the cloud symbol,"
echo "select the \"NIO TAP\" tab and add the \"tap0\" device"
echo "-------------------------------------------------------------------"
tunctl -u $GUSERNAME
ifconfig tap0 $GTAPIP netmask $GTAPMASK up
echo 1 > /proc/sys/net/ipv4/ip_forward
if [ "$GTAPNATENABLE" = "1" ]
then
echo "--- Enabling NAT on incoming ip on tap0 device"
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i tap0 -j ACCEPT
iptables -A INPUT -i tap0 -j ACCEPT
fi
if [ "$GROUTE2GNS3" = "1" ]
then
route add -net $GNS3NETWORK netmask $GNS3NETMASK gw $GTAPIP
fi
#
# become the current user and start a shell
su -l $GUSERNAME
#
# another root shell
/bin/bash
</pre>

搞明白这个脚本所做的事情应该容易的：

It should be easy to understand what this script does:

在容器中应用由docker传递自宿主机的那些环境变量来“克隆”当前用户（myrun.sh脚本中用到的多个-e选项），包括其主用户组；

"clone" the current user, including his primary group, in the container using environment variables passed by docker from the host to the container (the multiple -e options used in the myrun.sh script);

将“docker”作为口令指定给容器中的当前用户名（当你在容器中执行sudo命令时，需要提供该口令）

assign the password docker to the current user's username inside the container (needed if you want to execute e sudo inside the container);

生成IOU的许可证文件 /src/misc/iourc.lic，但在此之前你务必要将keygen.py文件放入$HOME/gns3-misc文件夹，否则就不能生成该许可证，你就用不上IOU。因为法律上的原因，此文件是不能放入到容器镜像中的。同时该许可证文件必须要在容器每次启动时生成，以为在容器每次启动时，它都会有不同的MAC地址，而许可证是受MAC地址影响的。

generate the IOU license file in /src/misc/iourc.lic , but to do so you have to put the keygen.py file in the folder $HOME/gns3-misc , otherwise no IOU license is generated and you will not be able to use IOU. For legal reasons this file cannot be included in the container image. The license file must be generated each time the container starts because, each time, it can have a different MAC address and the license is impacted by the MAC address;

创建一个归当前用户所有的tap0接口；如此便可以普通用户身份来运行gns3并无需root身份便可连接到云符号（the cloud symbol）上；

create the tap0 interface owned by the current user; in this way it is possible to run gns3 as a normal user and connect the cloud symbol to this interface without being root;

在容器里启用路由；

enable routing on the container；

如变量 GTAPNATENABLE为1，就在eth0接口上使用iptables来配置NAT；

if GTAPNATENABLE is 1 use iptables to configure NAT on the eth0 interface;

如变量 GROUTE2GNS3为1，就在容器中添加一条到gns3仿真网络的路由；

if GROUTE2GNS3 is 1 , instead, add a route to the gns3 emulated network on the container；

以用户的用户名开启一个shell

start a shell as the user's username

在上述shell终止后，运行另一个root shell。如此当推出一个普通shell后就能进入到root模式；而从该root shell退出就将终止该容器。

when the above shell terminate, runs another shell as root. In this way it is possibile to become root after exiting from the normal user shell; exiting from this root shell will stop the container.

在startup.sh完成用户shell的启动后，一个标准提示符等待着你，你会注意到那个主机名（hostname）不是你通常的主机名，而是通过-h选项提供给容器的主机名，这里是gns3-large:

When the startup.sh has started the user's shell you are greeted by a standard prompt and you can see that the hostname is not your usual hostname but the name you gave to the container with the -h option, gns3-large in our case:

<pre lang="sh">
valerio@ubuntu-hp:~/docker/gns3-large$ ./myrun.sh
[sudo] password for valerio:
-------------------------------------------------------------------
tap0 has address 10.123.1.1 netmask 255.255.255.0
if yuou use the cloud symbol to connect to the physical network
use an address on the same subnet, and, on the cloud symbol,
select the "NIO TAP" tab and add the "tap0" device
-------------------------------------------------------------------
Set 'tap0' persistent and owned by uid 1000
valerio@gns3-large:~$ hostname
gns3-large
valerio@gns3-large:~$
</pre>

##配置GNS3
##Configuring GNS3
要使用IOU，需要一个许可证文件生成器，通常叫做keygen.py，并要把它放到如下所示的主目录下的gns3-misc文件夹（容器将会此文件夹的位置，注意这里的“valerio”是我的用户名，你需要将其修改为你的用户名）：

To use IOU a license file generator is needed, it is usually called keygen.py and must be put in the folder gns3-misc under your home directory as shown below (the container will check this file location, please note that "valerio" is my username, you have to replace "valerio" with your username):

<pre lang="sh">
valerio@ubuntu-hp:~$ ls ~/gns3-misc/keygen.py
/home/valerio/gns3-misc/keygen.py
</pre>

因为法律方面的原因，本容器镜像不能包含此文件，但你可以用关键字“Cisco IOU License Generator v2”在google中进行搜索。（对于搜索或下载该文件是否合法，请咨询你的律师）。在从命令行启动gns3后，我们需要对其进行以下配置：

For legal reasons this file cannot be included in the container image, but can be searched on Google with a search string similar to "Cisco IOU License Generator v2". (I don't know if searching and downloading is legal or not, please check with your lawyer). After launching gns3 from the command line we have to configure gns3:

前往 Edit -> Preferences -> General，点击“Console applications”选项页，将字符串“gnome-terminal”改为“lxterminal”，并点击“OK”按钮；因为docker容器中的gnome-terminal有一些涉及其调用dbus系统的问题：

go to Edit -> Preferences -> General click Console applications tab and replace the string gnome-terminal with the string lxterminal and then click OK; this is needed because in the docker container gnome-terminal has some problems related to its use of the dbus system:











前往Edit -> Preferences -> IOS on UNIX:

go to Edit -> Preferences -> IOS on UNIX:

在“Path to IOURC”处，填入“/src/misc/iourc.txt”

in the Path to IOURC put the string /src/misc/iourc.txt

在“Path to iouyap”处，填入“/usr/local/bin/iouyap”；iouyap是一个将IOU的封装以太网帧转换GNS3所使用的UDP封装以太网帧格式的程序

in the Path to iouyap put the string /usr/local/bin/iouyap ; iouyap is a program that converts the encapsulated ethernet frame of IOU to an UDP encapsulated ethernet format used by GNS3

按下“Apply”和“OK”按钮

Press Apply and OK


现在我们要将IOU镜像装入到gns3中；同样因为法律的原因，这个镜像文件不能包含进入容器镜像，但是在与你的律师确认后，仍然可以在Google上搜索到这些文件。在互联网上有很多IOU镜像文件，但只有少数能在GNS3中良好运行；要么有着功能特性上的问题（比如CDP），要么因为它们因为STP不工作而在冗余配置中产生环回而无法使用；在gns3论坛上有一些关于在GNS3中最好镜像的有趣讨论。下面是一些建议：

now we load the IOU images into gns3; for legal reasons these files cannot be included in the container image, but, again, check with your lawyer, and search them on Google. There are a lot of IOU images floating on the Internet, but only few of them run smoothly in GNS3; some have problems with some features (like CDP), some others are unusable because they create loops in redundant configurations as if the STP protocol doesn't work; on the gns3 forum there are interesting discussions about what are the best images to run in GNS3. Some of the recommendations are:

i86bi_linux_l2-adventerprise-ms.nov11-2013-team_track.bin镜像，我用这个作为二层IOU，它工作得很好，所以我强烈建议你用这个

i86bi_linux_l2-adventerprise-ms.nov11-2013-team_track.bin i am using this one, for layer 2 IOU, it works flawlessly for me and I strongly recommend to use this one

i86bi_linux_l2-ipbasek9-ms.jan24-2013-B (15.1)镜像，一个用户说这个镜像支持很多二层特性，看起来也是很稳定的

i86bi_linux_l2-ipbasek9-ms.jan24-2013-B (15.1) a user says that it supports many L2 features. And looks so stable

另一个用户讲，用 i86bi-linux-l2-ipbasek9-15.1e.bin镜像做交换机，用 i86b-linux-l3-adventerprisek9-15.4.1T.bin镜像做路由器。是我目前发现的最稳定的镜像

another user says: i86bi-linux-l2-ipbasek9-15.1e.bin for Switches and i86b-linux-l3-adventerprisek9-15.4.1T.bin for Routers. These seem to be the 2 most stable images I've found

另一个用户讲，他用i86bi-linux-l2-adventerprise-15.1b.bin 镜像做交换机，用i86bi-linux-l3-adventerprisek9-15.4.2T.bin 镜像做路由器，用起来很稳定。

and another user: I use i86bi-linux-l2-adventerprise-15.1b.bin for Switches and i86bi-linux-l3-adventerprisek9-15.4.2T.bin for Routers. For me they work stable.

前往Edit -> Preferences -> IOS on UNIX, 点击小箭头，然后点击IOU Devices -> New

go to Edit -> Preferences -> IOS on UNIX, click the small arrow and then on IOU Devices -> New

在“Name”字段，我输入了“IOU-L2”

in the Name field I entered IOU-L2

在“IOU image”出，浏览并选择你所下载到的i86bi_linux_l2-adventerprise-ms.nov11-2013-team_track.bin 文件

in the IOU image browse to select the i86bi_linux_l2-adventerprise-ms.nov11-2013-team_track.bin file that you ave downloaded somewhere

在“Type”处，选择”L2 image”并点击“Finish”按钮

in Type select L2 image and then click Finish

在 Edit -> Network 处调整以太网适配器的数量（每个设备有4个接口）一串行通信适配器的数量，我总是将串行通信适配器设置为0, 因为交换机通常是没有串行接口的：

you can click Edit -> Network and adjust the number of Ethernet adapters (each one has 4 ports) and the number of Serial adapters, i prefer 0 Serial adapters, because usually switches don't have serial interfaces: 

点击“OK”按钮

click Ok

现在，我么要将思科路由器镜像装入进来；不是每个思科路由器都是由Dynamips仿真的（Dynamips是GNS3用到的思科仿真软件），也不是每个扩展卡都能仿真出来的，同时在GNS3中也存在一些固件比另一些工作得更好的情况；因此，听从社区关于最好的思科型号和固件镜像方面的建议尤为重要；下面是我所发现的那些建议：

now it's time to load a Cisco router image; not every cisco router is emulated by Dynamips (the Cisco emulator engine used by GNS3), not every expansion card is emulated and there are some firmware working better than others in GNS3; for this reason it is importat to follow community recommendation for the best Cisco model and firmware image; some of the recommendations I found are:

c3725-advipservicesk9-mz.124-23.bin 镜像是你所需的。这大概是用于GNS3的最好镜像了。这也是我所使用的镜像，同时我也强烈推荐你使用这个

c3725-advipservicesk9-mz.124-23.bin is what you want. This is pretty much the best image to use with GNS3. This i what I am using and strongly recommend

c3640-jk9s-mz.124-16.bin 这个镜像能在所有gns3vault实验中使用，所以它也是好用的

c3640-jk9s-mz.124-16.bin it works with all gns3vault labs so it's pretty handy

c3725-adventerprisek9-mz.124-15.T10.bin 一位用户讲：我在做一些实验中发现上面的镜像缺少某些特性，其中之一是IPv6的EIGRP时，我会用这个镜像

c3725-adventerprisek9-mz.124-15.T10.bin a user says: I use this for other labs as I found the above IOS was lacking a few features, one being EIGRP for IPv6

c2691-adventerprisek9-mz.124-25c.bin 另一位用户说：一直以来这个镜像我用得很好。但我要做的一些实验是CBT Nugget考试实验，因为他所使用的那些镜像，我受益很多

c2691-adventerprisek9-mz.124-25c.bin another user says: seems to be working well for me so far. But some test labs I am doing are CBT Nugget test labs so that helps with those since that is what he uses

要将一台思科路由器的镜像，前往 Edit -> Preferences -> Dynamips, 点击小箭头并在 IOS Routers -> New 中找到并选取你所下载的镜像 c3725-advipservicesk9-mz.124-23.bin，如果出现要解压缩该IOS镜像的对话框，就回答YES

to add a Cisco router and image go to Edit -> Preferences -> Dynamips, click the small arrow and then on IOS Routers -> New browse to select the image c3725-advipservicesk9-mz.124-23.bin you have downloaded, answer Yes if asked to decompress this IOS image

点击”Next”

click Next

将c3725作为名称和平台，在点击“Next”

accept c3725 as Name and Platform and click Next

默认的128MB内存即可，点击“Next”

accept the default RAM of 128 MB and click Next

在网络适配器处，插槽0上接受默认设置即可，GT96100-FE支持2个快速以太网接口，在插槽1上选择NM-4T模块，它支持4个串行通信接口

as Network adapters accept, on slot 0, the GT96100-FE that support 2 Fast Ethernet interfaces and put the NM-4T on slot 1, that support four serial interfaces

点击“Next”, 不要选择任何WIC模块，再次点击“Next”按钮，这里将会弹出一个询问Idle-PC值窗口; 此时忽略该项设置并点击“Finish”按钮。我们会在稍后来找出Idle-PC值；该值是非常重要的，因为在Dynamips仿真思科路由器时，它会在路由器处于空闲、等待某些事件发生时，仿真包括固件内主循环在内的一切东西。Idle-PC（PC是指程序计数器）是主循环中某条指令的内存地址，当gns3/dynamips获悉该地址后，将被用于暂停被仿真设备几个毫秒，这将在降低dynamips 的CPU周期上取得客观的效果（CPU负载可从100%降低到大约2-3%）

click Next, don't select any WIC modules, click Next again, a window, asking you an Idle-PC value, will pop-up; ignore for the moment and click Finish. We will find the Idle-PC value later; this value is very important, because when Dynamips emulate the Cisco router, it emulates everything, including the main loop in firmware, when the Cisco router is sitting idle, waiting for some event to happen. The idle-PC (PC is Program Counter) is the memory address of an instruction in the main loop, when this value is known by gns3/dynamips it will be used to pause few milliseconds the emulated device and this allows a dramatic reduction of dynamips CPU cycles (CPU load goes down from 100% to about 2-3%)

你可以输入更多的IOU及路由器镜像或者QEMU虚拟机镜像

you can input more IOU and router images or QEMU Virtual Machine images

其它比如抓包（wireshark）以及VPCS选项都有不错的默认值

the other options regarding Packet Capture (Wireshark) and VPCS have good default values

##一个简单的GNS3网络
##A simple GNS3 network
到这里，我们就可以在gns3中设计第一个网络了。

We are ready, now, to design our first network in gns3.

在设计区域，我们放入了云符号（the cloud symbol），在NIO TAP选项页上的TAP接口处，输入tap0并点击“Add”和“OK”按钮来添加tap0接口

We put the cloud symbol in the design area, add the tap0 interface to it clicking on the NIO TAP tab, entering tap0 in the TAP interface and then clicking on Add, Apply and OK

云符号是用于将我们的仿真网络通过tap0网络接口连接到外部世界。由于tap0是为当前用户所有，所以在使用tap0设备时无需以root用户运行gns3。

The cloud symbol is needed to connect our emulated network to the outside world through the tap0 network interface. Because tap0 is owned by the current user, we don't need to run gns3 as root to use the tap0 device.

现在我们添加路由器R1（上面配置好的C3725）、交换机IOU1(上面配置好的IOU交换机)以及PC1(虚拟PC仿真器)。

Now we add the router R1 (the C3725 configured above) the switch IOU1 (the IOU switch configured above) and PC1 (the virtual PC emulator). 

通过点击 Device -> Start，我们启动所有设备，不过在点击后我们的CPU负载将变得非常高，因为dynamips进程在对思科路由器进行仿真：

We start all devices clicking on Device -> Start, after clicking our CPU load goes very high due to the dynamips process emulating the Cisco router:

<pre lang="sh">
top - 20:14:35 up 43 min, 3 users, load average: 0,91, 0,57, 0,66
Tasks: 249 total, 1 running, 247 sleeping, 0 stopped, 1 zombie
%Cpu(s): 28,5 us, 1,2 sy, 0,0 ni, 62,8 id, 7,5 wa, 0,0 hi, 0,0 si, 0,0 st
KiB Mem: 8087792 total, 5195076 used, 2892716 free, 1022404 buffers
KiB Swap: 15625212 total,
0 used, 15625212 free. 1872536 cached Mem
PID USER	PR NI VIRT RES SHR S %CPU %MEM TIME+ COMMAND
11825 valerio 20 0 687352 271956 197856 S 100,2 3,4 1:10.44 dynamips
3795 valerio 20 0 961412 164292 60748 S 6,0 2,0 4:45.77 chrome
3835 valerio 20 0 846360 300028 86848 S 4,3 3,7 3:05.39 chrome
1290 root	20 0 267208 32696 21412 S 1,7 0,4 1:26.23 Xorg
15889 valerio 20 0 167124 2224 216 S 1,7 0,0 0:00.89 vpcs
6147 valerio 20 0 840308 144296 36804 S 1,3 1,8 0:38.35 chrome
8359 valerio 20 0 365028 25352 5900 S 0,7 0,3 0:28.85 gns3server
15892 valerio 20 0 268056 109336 58444 S 0,7 1,4 0:01.41 i86bi_linu+
</pre>

为降低CPU的使用，在路由器R1上右击，选择Idle-PC, 再接受那个建议值，之后点击“Apply”按钮并再次检查CPU负载；你可以尝试不同的Idle-PC值以找出有着较低CPU使用的那个；通常默认值就是较好的并能想下面那样显著降低CPU负载，从100%的CPU使用降低到仅2.7%

To lower the CPU usage right click the router R1 and Idle-PC, accept the proposed value, click Apply and check again the CPU load; you can try different values of Idle-PC to find the one with the lower CPU usage; usually the default value is OK and dramatically reduce CPU load as shown below where the dynamips process has moved from 100% CPU usage to only 2.7%

<pre lang="sh">
top - 20:19:57 up 48 min, 3 users, load average: 0,60, 0,85, 0,77
Tasks: 247 total, 2 running, 244 sleeping, 0 stopped, 1 zombie
%Cpu(s): 7,9 us, 3,6 sy, 0,0 ni, 84,9 id, 3,6 wa, 0,0 hi, 0,0 si, 0,0 st
KiB Mem: 8087792 total, 5195472 used, 2892320 free, 1023576 buffers
KiB Swap: 15625212 total,	0 used, 15625212 free. 1878992 cached Mem
PID USER PR NI VIRT RES SHR S %CPU %MEM TIME+ COMMAND
3795 valerio 20 0 961412 164768 60704 S 15,6 2,0 5:10.26 chrome
3835 valerio 20 0 852312 301748 92740 S 11,3 3,7 3:21.95 chrome
15889 valerio 20 0 167124 2224 216 S 4,3 0,0 0:06.05 vpcs
1290 root 20 0 269324 33896 22020 S 4,0 0,4 1:33.18 Xorg
8359 valerio 20 0 365028 25352 5900 R 2,7 0,3 0:32.63 gns3server
11825 valerio 20 0 687352 275272 197920 S 2,7 3,4 4:57.72 dynamips
6147 valerio 20 0 844716 135360 37340 S 2,3 1,7 0:45.85 chrome
15892 valerio 20 0 268056 109336 58444 S 1,3 1,4 0:03.66 i86bi_linu+
</pre>

tap0 接口的地址为10.123.1.1/24(这是myrun.sh环境变量设定的），因此我们需要连接到路由器R1的控制台并：

The tap0 interface has address 10.123.1.1/24 (because of myrun.sh environment variables), so we connect to the R1 router console and:

将其f0/0接口配置IP地址10.123.1.2/24(外部接口)

configure the IP 10.123.1.2/24 on his f0/0 interface (outside interface)

将其f0/1接口配置IP地址10.123.2.1/24(内部接口)

configure the IP 10.123.2.1/24 on his f0/1 interface (inside interface)

配置10.123.1.1作为默认网关

configure 10.123.1.1 as the defautl gateway

<pre lang="sh">
R1#conf t
Enter configuration commands, one per line. End with CNTL/Z.
R1(config)#interface fastethernet 0/0
R1(config-if)#ip address 10.123.1.2 255.255.255.0
R1(config-if)#no shutdown
R1(config-if)#exit
*Mar 1 00:25:01.075: %LINK-3-UPDOWN: Interface FastEthernet0/0, changed state to up
*Mar 1 00:25:02.075: %LINEPROTO-5-UPDOWN: Line protocol on Interface FastEthernet0/0, changed state to up
R1(config)#ip route 0.0.0.0 0.0.0.0 10.123.1.1
R1(config)#interface fastEthernet 0/1
R1(config-if)#no shutdown
R1(config-if)#ip address 10.123.2.1 255.255.255.0
R1(config-if)#exit
R1(config)#exit
R1#
*Mar 1 00:27:52.823: %SYS-5-CONFIG_I: Configured from console by consoleR1#write mem
Building configuration...
[OK]
R1#
</pre>

如此来配置IOU1:

to configure IOU1:

显式地将端口配置为接入模式

explicitly configure the ports in access mode

显式地将预定义的Vlan 1指定到每个端口

explicitly assign the predefined Vlan 1 to each port

将其所有接口都置为no shutdown模式

put in no shutdown his interfaces

将IP地址10.123.2.2指定到Vlan 1接口

assign the IP address 10.123.2.2 to the switch's Vlan 1 interface

<pre lang="sh">
IOU1#conf t
Enter configuration commands, one per line. End with CNTL/Z.
IOU1(config)#interface range ethernet 0/0 - 3
IOU1(config-if-range)#switchport mode access
IOU1(config-if-range)#switchport access vlan 1
IOU1(config-if-range)#no shutdown
IOU1(config-if-range)#exit
IOU1(config)#
*Nov 14 20:18:16.505: %LINK-3-UPDOWN: Interface Ethernet0/0, changed state to up
*Nov 14 20:18:16.505: %LINK-3-UPDOWN: Interface Ethernet0/1, changed state to up
*Nov 14 20:18:16.505: %LINK-3-UPDOWN: Interface Ethernet0/2, changed state to up
*Nov 14 20:18:16.505: %LINK-3-UPDOWN: Interface Ethernet0/3, changed state to up
*Nov 14 20:18:17.510: %LINEPROTO-5-UPDOWN: Line protocol on Interface Ethernet0/0, changed state to up
*Nov 14 20:18:17.510: %LINEPROTO-5-UPDOWN: Line protocol on Interface Ethernet0/1, changed state to up
*Nov 14 20:18:17.510: %LINEPROTO-5-UPDOWN: Line protocol on Interface Ethernet0/2, changed state to up
*Nov 14 20:18:17.510: %LINEPROTO-5-UPDOWN: Line protocol on Interface Ethernet0/3, changed state to up
IOU1(config)#interface range ethernet 1/0 - 3
IOU1(config-if-range)#switchport mode access
IOU1(config-if-range)#switchport access vlan 1
IOU1(config-if-range)#no shutdown
IOU1(config-if-range)#exit
IOU1(config)#
*Nov 14 20:20:15.711: %LINK-3-UPDOWN: Interface Ethernet1/0, changed state to up
*Nov 14 20:20:15.711: %LINK-3-UPDOWN: Interface Ethernet1/1, changed state to up
*Nov 14 20:20:15.711: %LINK-3-UPDOWN: Interface Ethernet1/2, changed state to up
*Nov 14 20:20:15.711: %LINK-3-UPDOWN: Interface Ethernet1/3, changed state to up
*Nov 14 20:20:16.718: %LINEPROTO-5-UPDOWN: Line protocol on Interface Ethernet1/0, changed state to up
*Nov 14 20:20:16.718: %LINEPROTO-5-UPDOWN: Line protocol on Interface Ethernet1/1, changed state to up
*Nov 14 20:20:16.718: %LINEPROTO-5-UPDOWN: Line protocol on Interface Ethernet1/2, changed state to up
*Nov 14 20:20:16.718: %LINEPROTO-5-UPDOWN: Line protocol on Interface Ethernet1/3, changed state to up
IOU1(config)#interface vlan 1
IOU1(config-if)#ip address 10.123.2.2 255.255.255.0
IOU1(config-if)#no shutdown
IOU1(config-if)#
*Nov 14 20:21:41.875: %LINK-3-UPDOWN: Interface Vlan1, changed state to up
*Nov 14 20:21:42.877: %LINEPROTO-5-UPDOWN: Line protocol on Interface Vlan1, changed state to up
IOU1(config-if)#exit
IOU1(config)#exit
IOU1#
*Nov 14 20:21:50.943: %SYS-5-CONFIG_I: Configured from console by console
IOU1#write mem
Building configuration...Compressed configuration from 1421 bytes to 890 bytes[OK]
IOU1#
</pre>


如此来配置PC1

to configure PC1

设置IP地址为10.123.2.10/24, 网关为10.123.2.1

<pre lang="sh">
assign it the IP 10.123.2.10/24 and gateway 10.123.2.1
PC1> ip 10.123.2.10/24 10.123.2.1
Checking for duplicate address...
PC1 : 10.123.2.10 255.255.255.0 gateway 10.123.2.1
PC1> save
. done
PC1>
</pre>

现在我们可以从每个设备对不同IP地址进行ping操作，比如从PC1进行如下操作：

Now we can try to ping various ip addresses from each device, for example from PC1:

我们可以ping 10.123.2.2(IOU1 交换机）

we can ping 10.123.2.2 (IOU1 switch)

我们可以ping 10.123.2.1(R1路由器的内部接口)

we can ping 10.123.2.1 (R1 router, inside interface)

我们可以ping 10.123.1.2(路由器R1的外部接口)

we can ping 10.123.1.2 (R1 router, outside interface)

我们可以ping 10.123.1.1(tap0 接口)

we can ping 10.123.1.1 (tun0 interface)

我们可以ping 172.17.0.2(docker 镜像eth0的IP地址)

we can ping 172.17.0.2 (the docker image eth0 IP address)

我们不能 ping 172.17.42.1(宿主机的docker0接口的IP地址)

we cannot ping 172.17.42.1 (the host docker0 IP address)

<pre lang="sh">
PC1> ping 10.123.2.2 -c 2
10.123.2.2 icmp_seq=1 ttl=255 time=0.604 ms
10.123.2.2 icmp_seq=2 ttl=255 time=0.559 ms
PC1> ping 10.123.2.1 -c 2
10.123.2.1 icmp_seq=1 ttl=255 time=6.968 ms
10.123.2.1 icmp_seq=2 ttl=255 time=5.947 ms
PC1> ping 10.123.1.2 -c 2
10.123.1.2 icmp_seq=1 ttl=255 time=4.472 ms
10.123.1.2 icmp_seq=2 ttl=255 time=6.667 ms
PC1> ping 10.123.1.1 -c 2
10.123.1.1 icmp_seq=1 ttl=63 time=22.386 ms
10.123.1.1 icmp_seq=2 ttl=63 time=16.871 ms
PC1> ping 172.17.0.2
172.17.0.2 icmp_seq=1 ttl=63 time=15.985 ms
172.17.0.2 icmp_seq=2 ttl=63 time=17.817 ms
PC1> ping 172.17.42.1 -c 2
172.17.42.1 icmp_seq=1 timeout
172.17.42.1 icmp_seq=2 timeout
</pre>


这里我们不能ping通宿主机的docker0接口（也就是接上tap0 的“管线”的另一端），这是因为我们的gns3网络以及docker镜像知道怎样向外部世界发送数据包，但宿主机却不知道往哪里发送到10.123.0.0/16网络的数据包，因此我们需要执行脚本hostroute2gns3来添加所需的路由：

We cannot ping the docker0 host interface (the other end of the "pipe" attached to tap0) because our gns3 network and our docker image know where to send packets to the external world, but the host doesn't know where to send packets to the network 10.123.0.0/16, so we need to execute the script hostroute2gns3 that adds the needed route:

<pre lang="sh">
valerio@ubuntu-hp:~/docker/gns3-large$ sudo ./hostroute2gns3
Container ID: 2d7205472e80
Container IP: 172.17.0.2
removing existing route
adding route
valerio@ubuntu-hp:~/docker/gns3-large$ netstat -nr
Kernel IP routing table
Destination   Gateway       Genmask         Flags   MSS   Window	  irtt  	Iface
0.0.0.0       192.168.2.1   0.0.0.0		      UG	    0 	  0	        0	      eth0
10.123.0.0    172.17.0.2    255.255.0.0	    UG	    0	    0	        0	      docker0
172.17.0.0    0.0.0.0       255.255.0.0	    U	      0	    0	        0	      docker0
192.168.2.0   0.0.0.0       255.255.255.0	  U	      0	    0	        0	      eth0
</pre>


为将我们的仿真网络连接至互联网，我们还需要在ADSL路由器上设置一条到达10.123.0.0/16网络的路由，将宿主机的IP地址（此处的192.168.2.32）作为到该网络的默认网关。在完成这些设置后，我们可以做到这些：

To connect our emulated network to the Internet we need also to put a route on our ADSL router to reach the 10.123.0.0/16 network using as gateway the IP address of our host (192.168.2.32 in this case). Having done this we can now:

ping 172.17.42.1(宿主机的docker0接口）

ping 172.17.42.1 (our host, docker0 interface)

ping 192.168.2.32(主机的eth0接口)

ping 192.168.2.32 (our host, eth0 interface)

ping 192.168.2.1(ADSL路由器)

ping 192.168.2.1 (our ADSL router)

ping 8.8.8.8(互联网上的Google公共DNS服务器)

ping 8.8.8.8 (on the Internet, Google's public DNS server)

<pre lang="sh">
PC1> ping 172.17.42.1 -c 2
172.17.42.1 icmp_seq=1 ttl=62 time=19.906 ms
172.17.42.1 icmp_seq=2 ttl=62 time=15.904 ms
PC1> ping 192.168.2.32 -c 2
192.168.2.32 icmp_seq=1 ttl=62 time=11.028 ms
192.168.2.32 icmp_seq=2 ttl=62 time=15.963 ms
PC1> ping 192.168.2.1 -c 2
192.168.2.1 icmp_seq=1 ttl=61 time=17.163 ms
192.168.2.1 icmp_seq=2 ttl=61 time=15.727 ms
PC1> ping 8.8.8.8 -c 2
8.8.8.8 icmp_seq=1 ttl=44 time=43.010 ms
8.8.8.8 icmp_seq=2 ttl=44 time=46.294 ms
PC1>
</pre>

##使用Gnome连接管理器
##Using Gnome Connection Manager
GNS3中对每个设备控制台的访问已是十分便利的了，但如果你有着众多设备，有对每个设备都有一个tab页的话将变得更为容易。

The easy access to each device console in GNS3 is really handy, but if you have many devices it would be easier to have a tabbed terminal emulator with a tab for each device.

Gnome连接管理器（gcm）有着满足这种需求的特性，但却不能从GNS3中直接使用，为此我写了一个小的perl脚本gcmconf，它通过读取GNS3项目文件并创建或更新Gnome连接管理器的配置文件，从而使得对gns3项目中所有控制的访问变得异常容易。比如：

Gnome Connection Manager (gcm) has exactly this feature, but cannot be used directly from GNS3, for this reason I wrote a small perl script, gcmconf that reads the GNS3 project files and create, or update, the Gnome Connection Manager configuration file so it will be ultra easy to access all the consoles of our gns3 projects. For example:

<pre lang="sh">
valerio@gns3-large:~$ gcmconf
opening: /home/valerio/.gcm/gcm.conf
---- processing /home/valerio/GNS3/projects/tutorial/tutorial.gns3
Writing the new /home/valerio/.gcm/gcm.conf file
valerio@gns3-large:~$ gcm &
[1] 146
valerio@gns3-large:~$ gns3
</pre>

