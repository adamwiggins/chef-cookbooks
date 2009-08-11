#
# Cookbook Name:: redis
# Recipe:: default
#

template "/etc/redis.conf" do
  require 'sha1'
  password = SHA1::sha1("#{Time.now.to_f} #{rand} #{object_id}").to_s.slice(0, 20)
  port = 6379

  name = 'Redis'
  url = "redis://:#{password}@localhost:#{port}/0"
  File.open('/root/resources', 'a') do |f|
    f.puts "#{name}: #{url}"
  end

  owner 'root'
  group 'root'
  mode 0644
  source 'redis.conf.erb'
  variables(:port => port, :password => password, :logfile => '/var/log/redis.log')
end


bash "install_redis" do
  user "root"
  cwd "/tmp"
  code <<-EOBASH
    wget http://redis.googlecode.com/files/redis-0.900_2.tar.gz
    tar xzf redis-0.900_2.tar.gz
    cd redis-0.900
    make
    cd ..
    mv redis-0.900 /usr/local/redis
  EOBASH
  not_if "test -d /usr/local/redis"
end

bash "start_redis" do
  user "root"
  cwd "/usr/local/redis"
  code <<-EOBASH
    ./redis-server /etc/redis.conf
  EOBASH
  not_if "netstat -lptn | grep :6379"
end

