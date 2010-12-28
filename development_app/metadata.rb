maintainer       "Joakim Kolsjö"
maintainer_email "joakim.kolsjo;AT;gmail;DOT;com"
license          "Apache 2.0"
description      "Setup an application for development using nginx and passenger"
version          "0.1.0"

%w{ ubuntu }.each do |os|
  supports os
end
