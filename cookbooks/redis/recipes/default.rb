#
# Cookbook Name:: redis
# Recipe:: default
#

template "/usr/local/redis/redis.conf" do
  owner 'root'
  group 'root'
  mode 0644
  source 'redis.conf.erb'
  variables(:port => 6379, :logfile => '/var/log/redis.log')
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
    ./redis-server redis.conf
  EOBASH
  not_if "netstat -lptn | grep :6379"
end

