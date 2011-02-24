maintainer        "Bukowskis"
maintainer_email  "joakim.kolsjo;AT;bukowskis;DOT;com"
license           "Apache 2.0"
description       "Installs memcached from source and provides a define to set up an instance of memcache via runit"
version           "0.0.1"
depends           "runit"

%w{ ubuntu debian }.each do |os|
  supports os
end
