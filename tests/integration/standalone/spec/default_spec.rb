require "spec_helper"
require "net/http"

class ServiceNotReady < StandardError
end

sleep 10 if ENV["JENKINS_HOME"]

context "after provisioning finished" do
  describe server(:server1) do
    it "creates mytest database" do
      result = current_server.ssh_exec("influx -execute 'CREATE DATABASE mytest' && echo OK")
      expect(result).to match(/OK/)
    end

    it "shows mytest database" do
      result = current_server.ssh_exec("influx -execute 'SHOW DATABASES'")
      expect(result).to match(/^mytest$/)
    end
  end

  describe "local machine" do
    # curl -v http://192.168.21.200:1880/flows -H "Content-Type: application/json" --data "@mytest.json"
    it "uploads mytest.json to node-red" do
      uri = URI("http://#{server(:server1).server.address}:1880/flows")
      req = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
      req.body = File.read("mytest.json")
      res = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
      end
      expect(res.code.to_i).to eq 204
    end
  end
  describe server(:server1) do
    it "has random values in mytest database" do
      result = current_server.ssh_exec("sleep 10; influx -precision rfc3339 -database mytest -execute 'SELECT COUNT(value) FROM random'")
      expect(result).to match(/^1970-01-01T00:00:00Z\s+\d+/)
    end
  end
end
