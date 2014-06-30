# encoding: UTF-8
#
python_pip node['beaver_hashes']['pip_package'] do
  action :install
end
