package 'postgresql-9.1'

execute 'create-postgresql-cluster' do
  command "sudo pg_createcluster 9.1 main"
  not_if "test -d /etc/postgresql/9.1/main"
end

service 'postgresql' do
  provider Chef::Provider::Service::Init::Debian
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

db_name = node.deis.database.name
db_user = node.deis.database.user

execute 'create-deis-database' do
    user 'postgres'
    group 'postgres'
    db_exists = <<-EOF
    psql -c "select * from pg_database WHERE datname='#{db_name}'" | grep -c #{db_name}
    EOF
    command "createdb --encoding=utf8 --template=template0 #{db_name}"
    not_if db_exists, :user => 'postgres'
end

execute 'create-deis-database-user' do
    user 'postgres'
    group 'postgres'
    user_exists = <<-EOF
    psql -c "select * from pg_user where usename='#{db_user}'" | grep -c #{db_user}
    EOF
    command "createuser --no-superuser --no-createrole --no-createdb --no-password #{db_user}"
    not_if user_exists, :user => 'postgres'
end
