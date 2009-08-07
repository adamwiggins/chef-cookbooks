#
# Cookbook Name:: couchdb
# Recipe:: default
#

package "couchdb" do
	version "0.8.0"
end

directory "/db/couchdb/log" do
	owner "couchdb"
	group "couchdb"
	mode 0755
	recursive true
end

template "/etc/couchdb/couch.ini" do
	owner 'root'
	group 'root'
	mode 0644
	source "couch.ini.erb"
	variables({
		:basedir => '/db/couchdb',
		:logfile => '/db/couchdb/log/couch.log',
		:bind_address => '0.0.0.0',
		:port	=> '5984',
		:doc_root => '/usr/share/couchdb/www',
		:loglevel => 'info'
	})
end

remote_file "/etc/init.d/couchdb" do
	source "couchdb"
	owner "root"
	group "root"
	mode 0755
end

execute "add-couchdb-to-default-run-level" do
	command %Q{
		rc-update add couchdb default
	}
	not_if "rc-status | grep couchdb"
end

execute "ensure-couchdb-is-running" do
	command %Q{
		/etc/init.d/couchdb restart
	}
	not_if "/etc/init.d/couchdb status | grep 'status:	started'"
end
