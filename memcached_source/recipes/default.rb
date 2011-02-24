#
# Cookbook Name:: memcached_source
# Recipe:: default
#
# Copyright:: 2011, Bukowskis
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

include_recipe "build-essential"

package "libevent-dev"

remote_file "/tmp/memcached-#{node[:memcached][:version]}.tar.gz" do
  source "http://memcached.googlecode.com/files/memcached-#{node[:memcached][:version]}.tar.gz"
  not_if { ::File.exists?("/tmp/memcached-#{node[:memcached][:version]}.tar.gz") }
end

bash "Install memcached" do
  cwd "/tmp"
  code <<-EOH
  tar xfz /tmp/memcached-#{node[:memcached][:version]}.tar.gz
  cd memcached-1.4.4
  ./configure && make && make install
  EOH
  not_if do
    File.exists?("/usr/local/bin/memcached") && `/usr/local/bin/memcached -h|head -1|awk '{ print $2 }'`.chomp == node[:memcached][:version]
  end
end

template "/usr/local/bin/start-memcached" do
  source "start-memcached.erb"
  owner "root"
  group "root"
  mode "0755"
end

template "/etc/init.d/memcached" do
  source "memcached.erb"
  owner "root"
  group "root"
  mode "0755"
end

service "memcached" do
  action :nothing
  supports :status => false, :start => true, :stop => true, :restart => true
end
 
template "/etc/memcached.conf" do
  source "memcached.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :listen => node[:memcached][:listen],
    :user => node[:memcached][:user],
    :port => node[:memcached][:port],
    :memory => node[:memcached][:memory]
  )
  notifies :restart, resources(:service => "memcached"), :immediately
end
