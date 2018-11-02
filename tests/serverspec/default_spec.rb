require "spec_helper"
require "serverspec"

package = "node_red"
service = "node_red"
config  = "/etc/node_red/node_red.conf"
user    = "node_red"
group   = "node_red"
ports   = [PORTS]
log_dir = "/var/log/node_red"
db_dir  = "/var/lib/node_red"

case os[:family]
when "freebsd"
  config = "/usr/local/etc/node_red.conf"
  db_dir = "/var/db/node_red"
end

describe package(package) do
  it { should be_installed }
end

describe file(config) do
  it { should be_file }
  its(:content) { should match Regexp.escape("node_red") }
end

describe file(log_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

describe file(db_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

case os[:family]
when "freebsd"
  describe file("/etc/rc.conf.d/node_red") do
    it { should be_file }
  end
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
