maintainer       "Joakim Kolsjö"
maintainer_email "joakim.kolsjo;AT;gmail;DOT;com"
license          "Apache 2.0"
description      "Installs a PXE install server for installing ubuntu servers using kickstart."
version          "0.1.2"

%w{ ubuntu }.each do |os|
  supports os
end
