include_recipe "logrotate"

logrotate_app "logstash_beaver" do
  cookbook "logrotate"
  path log_file
  frequency "daily"
  postrotate "invoke-rc.d logstash_beaver force-reload >/dev/null 2>&1 || true"
  options [ "missingok", "notifempty" ]
  rotate 30
  create "0440 #{node['logstash']['user']} #{node['logstash']['group']}"
end
