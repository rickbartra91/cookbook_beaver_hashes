# encoding: UTF-8
#
if node['logstash']['install_zeromq']
  case
  when platform_family?('rhel')
    include_recipe 'yumrepo::zeromq'
  when platform_family?('debian')
    apt_repository 'zeromq-ppa' do
      uri 'http://ppa.launchpad.net/chris-lea/zeromq/ubuntu'
      distribution node['lsb']['codename']
      components ['main']
      keyserver 'keyserver.ubuntu.com'
      key 'C7917B12'
      action :add
    end
    apt_repository 'libpgm-ppa' do
      uri 'http://ppa.launchpad.net/chris-lea/libpgm/ubuntu'
      distribution node['lsb']['codename']
      components ['main']
      keyserver 'keyserver.ubuntu.com'
      key 'C7917B12'
      action :add
      notifies :run, 'execute[apt-get update]', :immediately
    end
  end
  node['logstash']['zeromq_packages'].each { |p| package p }
  python_pip node['logstash']['beaver']['zmq']['pip_package'] do
    action :install
  end
end
