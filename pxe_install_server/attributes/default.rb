# Which versions of ubuntu to provide:
default[:pxe_install_server][:releases] = { "ubuntu-11.04" => "11.04/ubuntu-11.04-server-amd64" }

# Which version of ubuntu to install and what options to give to the templates for each server:
# default[:pxe_install_server][:servers] = [
#   { :mac => "00:50:56:00:00:03", :release => "ubuntu-11.04", :ip => "172.20.20.20", :hostname => "foo" }
# ]

# In additon to changing these settings, you'll want to override the templates and provide config
# that matches your network setup.

