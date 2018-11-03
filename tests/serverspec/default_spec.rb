require "spec_helper"
require "serverspec"

package = "node-red"
service = "node_red"
root_dir = "/opt/node-red"
user    = "node_red"
group   = "node_red"
ports   = [1880]

case os[:family]
when "freebsd"
  root_dir = "/usr/local/node-red"
end
config = "#{root_dir}/settings.js"

describe command "npm list -g --depth 0" do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  its(:stdout) { should match(/^\+-- #{package}@\d+\.\d+\.\d+$/) }
end

describe file(config) do
  it { should exist }
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
  its(:content) { should match(%r{^// Managed by ansible$}) }
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
