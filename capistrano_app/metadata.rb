maintainer       "Joakim Kolsjö"
maintainer_email "joakim.kolsjo;AT;gmail;DOT;com"
license          "Apache 2.0"
description      "Prepares a directory and config for capistrano and adds a vhost for apache2/passenger."
version          "0.1.0"

%w{ ubuntu debian }.each do |os|
  supports os
end
