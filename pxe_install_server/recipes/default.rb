#
# Cookbook Name:: pxe_install_server
#
# Recipe:: default
#
# Copyright 2011, Joakim Kolsjö
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package "openbsd-inetd"
package "tftpd-hpa"
package "dhcp3-server"
package "apache2"

node[:pxe_install_server][:releases].each do |release, path|
  remote_file "/tmp/#{release}.iso" do
    source "http://ftp.sunet.se/pub/Linux/distributions/ubuntu/ubuntu-cd/#{path}.iso"
    not_if { File.exists?("/var/www/#{release}") || File.exists?("/tmp/#{release}.iso") }
  end

  bash "Mount iso" do
    code "mkdir -p /media/#{release} && mount -o loop /tmp/#{release}.iso /media/#{release}"
    not_if { 
      File.exists?("/var/www/#{release}") || system("mount|grep #{release} 1> /dev/null")
    }
  end

  bash "Copy netboot files" do
    cwd "/var/lib/tftpboot"

    code <<EOH
      mkdir -p /var/lib/tftpboot/pxelinux.cfg &&
      mkdir -p /var/lib/tftpboot/#{release} &&
      cp -r /media/#{release}/install/netboot/* /var/lib/tftpboot/#{release} &&
      ln -s #{release}/$(readlink /var/lib/tftpboot/#{release}/pxelinux.0) pxelinux.0.#{release}
EOH
    not_if { File.exists?("/var/lib/tftpboot/pxelinux.0.#{release}") }
  end

  bash "Copy ubuntu files" do
    code "mkdir -p /var/www/#{release} && cp -r /media/#{release}/* /var/www/#{release}/"
    not_if { File.exists?("/var/www/#{release}") }
  end

  bash "Unmount and remove iso" do
    code "umount /media/#{release} && rm /tmp/#{release}.iso"
    only_if { system("mount|grep #{release} 1> /dev/null") }
  end

  # http://administratosphere.wordpress.com/2011/04/29/ubuntu-kickstart-installs-and-corrupt-packages-file/
  bash "Prevent 'Debootstrap warning' error later on" do
    code "gunzip /var/www/#{release}/dists/lucid/restricted/binary-amd64/Packages.gz"
    not_if { !File.exists?("/var/www/#{release}/dists/lucid") || File.exists?("/var/www/#{release}/dists/lucid/restricted/binary-amd64/Packages") }
  end
end

service "networking" do
  supports :restart => true
end

service "dhcp3-server"  do
  supports :restart => true
end

service "tftpd-hpa"  do
  supports :restart => true
end

template "/etc/network/interfaces" do
  source "interfaces.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, resources(:service => "networking")
end

template "/etc/dhcp3/dhcpd.conf" do
  source "dhcpd.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables({ :servers => node[:pxe_install_server][:servers] })
  notifies :restart, resources(:service => "dhcp3-server")
end

node[:pxe_install_server][:servers].each do |server|
  mac = server[:mac].downcase.gsub(/:/, '-')

  template "/var/www/#{mac}.cfg" do
    source "ks.erb"
    mode 0644
    variables(server)
  end

  template "/var/lib/tftpboot/pxelinux.cfg/01-#{mac}" do # It looks for 01-#{mac} for some reason.
    source "pxelinux.erb"
    mode 0644
    variables({
      :mac => mac,
      :release => server[:release]
    })

    notifies :restart, resources(:service => "tftpd-hpa"), :delayed
  end
end

template "/etc/iptables.sh" do
  source "iptables.sh.erb"
  mode 0755
end

template "/etc/rc.local" do
  source "rc.local.erb"
  mode 0755
end

bash "Load iptables" do
  code "/etc/iptables.sh"
end

