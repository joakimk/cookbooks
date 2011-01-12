maintainer       "Joakim Kolsjö"
maintainer_email "joakim.kolsjo;AT;gmail;DOT;com"
license          "Apache 2.0"
description      "Installs apache2-mpm-prefork"
version          "0.1.0"

%w{ ubuntu debian }.each do |os|
  supports os
end
