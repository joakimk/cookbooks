#
# Cookbook Name:: capistrano_app
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

include_recipe "passenger_enterprise"

ruby_block "Preparing for deployment with capistrano" do
  block do
    node[:capistrano_app].each do |app, opts|
      next if File.exists?(opts[:deploy_to])
      require 'ftools'
      deploy_to = opts[:deploy_to]
      FileUtils.mkdir_p deploy_to + "/shared/config"
      FileUtils.mkdir_p deploy_to + "/shared/log"
      FileUtils.mkdir_p deploy_to + "/releases"
      FileUtils.chown_R opts[:user], nil, deploy_to
    end
  end

  action :create
  not_if { node[:capistrano_app].values.all? { |opts| File.exists?(opts[:deploy_to]) } }
end

node[:capistrano_app].each do |app, opts|
  opts[:shared_config].each do |file|
    template "#{opts[:deploy_to]}/shared/config/#{file}" do
      source "#{file}.erb"
      owner opts[:user]
      variables :environment => opts[:environment]
    end
  end

  template "#{node[:apache][:dir]}/sites-available/#{app}" do
    source "rails_app.conf.erb"
    owner "root"
    group "root"
    mode 0644
    variables(
      :root_dir => opts[:deploy_to] + "/current",
      :server_name => opts[:server_name],
      :environment => opts[:environment]
    )
    if File.exists?("#{node[:apache][:dir]}/sites-enabled/#{app}")
      notifies :reload, resources(:service => "apache2"), :delayed
    end
    not_if { File.exists?("#{node[:apache][:dir]}/sites-enabled/#{app}") }
  end

  apache_site app
end
