require "spec_helper"
require "serverspec"

package = "node-red"
service = "node_red"
db_dir = "/var/lib/node-red"
user    = "node-red"
group   = "node-red"
ports   = [1880]
log_file = "/var/log/syslog"
extra_npm_packages = %w[node-red-contrib-influxdb]
conf_dir = "/etc/node-red"
default_user = "root"
default_group = "root"

case os[:family]
when "freebsd"
  db_dir = "/var/db/node-red"
  log_file = "/var/log/messages"
  conf_dir = "/usr/local/etc/node-red"
  default_group = "wheel"
end
config = "#{conf_dir}/settings.js"

describe command "npm list -g --depth 0" do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  its(:stdout) { should match(/^\+-- #{package}@\d+\.\d+\.\d+$/) }
  extra_npm_packages.each do |p|
    its(:stdout) { should match(/^\+-- #{p}@\d+\.\d+\.\d+$/) }
  end
end

describe file(config) do
  it { should exist }
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
  its(:content) { should match(%r{^// Managed by ansible$}) }
end

describe file db_dir do
  it { should exist }
  it { should be_directory }
  it { should be_owned_by user }
  it { should be_grouped_into group }
  it { should be_mode 755 }
end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end

describe file log_file do
  its(:content) { should match(/node_red.*Server now running at http/) }
end
