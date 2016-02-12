#!/bin/bash
#
# This script will hopefully save you a lot of time setting up GCE 
# (Google Compute Engine) to be ready to run TensorFlow.
#
# Tested using the following environment:
# - n1-highcpu-4 instance with 3.6GB RAM
# - Running vanilla Ubuntu Trusty 14.04 LTS.
# - 20GB persistent disk.
#
# @author Jason Mayes
#
# Excessive commenting has been included below for clarity :-)
# Save this script to /home/yourUserName, chmod +x setupTensorFlowGCE.sh, + run
# using ./setupTensorFlowGCE.sh

mkdir tensorflow
cd tensorflow

################################################################################
# Install utils.
################################################################################
echo -e "\e[36m***Installing utilities*** \e[0m"
sudo apt-get update
sudo apt-get install unzip git-all pkg-config zip g++ zlib1g-dev

################################################################################
# Install Java deps.
################################################################################
echo -e "\e[36m***Installing Java8. Press ENTER when prompted*** \e[0m"
echo -e "\e[36m***And accept licence*** \e[0m"
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
sudo apt-get install oracle-java8-installer

################################################################################
# Install Bazel dep.
################################################################################
echo -e "\e[36m***Installing Bazel*** \e[0m"
wget https://goo.gl/W0Jztd -O bazel-0.1.5-installer-linux-x86_64.sh
chmod +x bazel-0.1.5-installer-linux-x86_64.sh
sudo ./bazel-0.1.5-installer-linux-x86_64.sh --user
rm bazel-0.1.5-installer-linux-x86_64.sh
sudo chown $USER:$USER ~/.cache/bazel/
sudo echo "PATH=\$PATH:\$HOME/bin" >> ~/.bashrc

################################################################################
# Fetch Swig and Python deps.
################################################################################
echo -e "\e[36m***Installing python deps*** \e[0m"
sudo apt-get install swig
sudo apt-get install build-essential python-dev python-pip checkinstall
sudo apt-get install libreadline-gplv2-dev libncursesw5-dev libssl-dev \
libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev

################################################################################
# Fetch and install Python.
################################################################################
echo -e "\e[36m***Installing Python*** \e[0m"
wget https://www.python.org/ftp/python/2.7.10/Python-2.7.10.tgz
tar -xvf Python-2.7.10.tgz
cd Python-2.7.10
./configure
make
sudo make install
cd ../
rm Python-2.7.10.tgz
sudo echo "alias python=python2.7" >> ~/.bashrc
source ~/.bashrc

################################################################################
# Grab latest TensorFlow from git.
################################################################################
echo -e "\e[36m***Cloning TensorFlow from GitHub*** \e[0m"
git clone --recurse-submodules https://github.com/tensorflow/tensorflow
sed -i 's/kDefaultTotalBytesLimit = 64/kDefaultTotalBytesLimit = 128/' tensorflow/google/protobuf/src/google/protobuf/io/coded_stream.h

################################################################################
# We need Numpy for this Tensor flow to work.
################################################################################
echo -e "\e[36m***Installing Numpy*** \e[0m"
sudo apt-get install python-numpy
sudo pip install numpy --upgrade

################################################################################
# GCE has no swap, prevent trying to use one else out of virtual memory error.
################################################################################
echo -e "\e[36m***Changing swappiness*** \e[0m"
sudo sysctl vm.swappiness=0
# Make change persistent even after reboot.
cp /etc/sysctl.conf /tmp/
echo "vm.swappiness=0" >> /tmp/sysctl.conf
sudo cp /tmp/sysctl.conf /etc/

################################################################################
# Make a swap which is used only if RAM not available.
################################################################################
echo -e "\e[36m***Creating swap file*** \e[0m"
sudo touch /var/swap.img
sudo chmod 600 /var/swap.img
# Create approx 4GB swap assuming 3.6GB RAM (almost 8GB total space available)
sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=4000
sudo mkswap /var/swap.img
sudo swapon /var/swap.img
free
echo -e "\e[36mReady to run TensorFlow! \e[0m"

################################################################################
# Now let's configure tensor flow.
################################################################################
echo -e "\e[36m***Configuring TensorFlow*** \e[0m"
echo -e "\e[36mType /usr/bin/python for config and say NO to GPU support. \e[0m"
echo -e "\e[36mRunning configure: \e[0m"
cd tensorflow
./configure
