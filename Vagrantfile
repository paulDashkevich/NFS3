# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
  :server => {
        :box_name => "centos/7",
	:box_version => "1804.02",
        :ip_addr => '192.168.11.101'
        },
  :client => {
	:box_name => "centos/7",
        :box_version => "1804.02",
	:ip_addr => '192.168.11.102'
	},
   }
   
Vagrant.configure("2") do |config|

  MACHINES.each do |boxname, boxconfig|
	config.vm.box_version = "1804.02"
	config.vm.define boxname do |box|
          box.vm.box = boxconfig[:box_name]
          box.vm.host_name = boxname.to_s
          box.vm.network "private_network", ip: boxconfig[:ip_addr]
          box.vm.provider :virtualbox do |vb|
            	  vb.customize ["modifyvm", :id, "--memory", "1024"]
end
 	  box.vm.provision "shell", inline: <<-SHELL
	      mkdir -p ~root/.ssh
              cp ~vagrant/.ssh/auth* ~root/.ssh
		 sudo su
		 yum install nfs-utils -y
		 yum install firewalld -y 
	         systemctl start firewalld.service
		 systemctl enable firewalld.service; exit 0
	SHELL

	 end
	end
	
	config.vm.define "server" do |server|
        server.vm.provision "shell", inline: <<-SHELL
            echo `hostname`
	    chmod +x /vagrant/scripts/server.sh
	    /vagrant/scripts/server.sh
	    yum install mc -y
            exit 0
        SHELL
       end
       config.vm.define "client" do |client|
        client.vm.provision "shell", inline: <<-SHELL
            echo `hostname`
	    chmod +x /vagrant/scripts/client.sh
            /vagrant/scripts/client.sh
            exit 0
            SHELL
       end

end
