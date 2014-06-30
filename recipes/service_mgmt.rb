# encoding: UTF-8
#
# use upstart when supported to get nice things like automatic respawns
# TODO: all cross-concern logic for what kind of service management to use
# should be centralized to a cookbook library that all the cookbooks can use
use_upstart = false
supports_setuid = false
case node['platform_family']
when 'rhel'
  use_upstart = true if node['platform_version'].to_i >= 6
when 'fedora'
  use_upstart = true if node['platform_version'].to_i >= 9
when 'debian'
  use_upstart = true
  supports_setuid = true if node['platform_version'].to_f >= 12.04
end

format    = node['beaver_hashes']['format']
conf_file = 'node.beaver_hashes.config_file'
output = 'node.beaver_hashes.output.type'
cmd = "beaver  -t #{output} -c #{conf_file} -F #{format}"

if use_upstart
  template '/etc/init/logstash_beaver.conf' do
    mode '0644'
    source 'logstash_beaver.conf.erb'
    variables(
              cmd: cmd,
              group: node['beaver_hashes']['group'],
              user: node['beaver_hashes']['user'],
              log: 'node.beaver_hashes.log_file',
              supports_setuid: supports_setuid
              )
    notifies :restart, 'service[logstash_beaver]'
  end

  service 'logstash_beaver' do
    supports restart: true, reload: false
    action [:enable, :start]
    provider Chef::Provider::Service::Upstart
  end
else
  template '/etc/init.d/logstash_beaver' do
    mode '0755'
    source 'init-beaver.erb'
    variables(
              cmd:  cmd,
              pid_file: 'node.beaver_hashes.pid_file',
              user: node['beaver_hashes']['user'],
              log: 'node.beaver_hashes.log_file',
              platform: node['platform']
              )
    notifies :restart, 'service[logstash_beaver]'
  end

  service 'logstash_beaver' do
    supports restart: true, reload: false, status: true
    action [:enable, :start]
  end
end
