name             "beaver_hashes"
maintainer       "Jordan curzon"
maintainer_email "curzonj@gmail.com"
license          "Apache 2.0"
description      "Installs/Configures beaver"
version          "0.0.1"

%w{ ubuntu debian redhat centos scientific amazon fedora }.each do |os|
    supports os
end

%w{ logstash python }.each do |ckbk|
    depends ckbk
end
