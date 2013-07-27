include_recipe "logstash::default"
include_recipe "python::default"

# TODO just use zeromq::python or something like it
include_recipe "beaver_hashes::zeromq"

include_recipe "beaver_hashes::layout"
include_recipe "beaver_hashes::install"
include_recipe "beaver_hashes::config_file"
include_recipe "beaver_hashes::service_mgmt"
include_recipe "beaver_hashes::logrotate"
