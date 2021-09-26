require 'docker'
require 'rake'
require 'pg'

def execute_build(conn)
  Rake::Task['schema.sql'].invoke
  begin
    File.open('build/schema.sql', 'r') {|f| conn.exec(f.read)}
  rescue PG::Error => e
    puts "Error: " + e.inspect
    raise e
  end
  FileUtils.rm('build/schema.sql')
  Rake::Task.tasks.each(&:reenable)
end


# Init rake
Rake.load_rakefile('Rakefile')

begin
  existing_container = Docker::Container.get('testdb')
  existing_container.stop
  existing_container.delete
rescue Docker::Error::NotFoundError
  # nothing to do
end

postgres_container = Docker::Container.create(
  'name' => 'testdb',
  'Image' => 'postgres:13',
  'ExposedPorts' => { '5432/tcp' => {} },
  'ENV' => ['POSTGRES_HOST_AUTH_METHOD=trust'],
  'HostConfig' => {
    'PortBindings' => {
      '5432/tcp' => [{ 'HostPort' => '5432', 'HostIp' => '127.0.0.1' }]
    }
  }
)

postgres_container.start

tries = 0
while PG::Connection.ping(dbname: 'postgres', host: '127.0.0.1', user: 'postgres') != PG::PQPING_OK do
  raise "Exceeded connections tentatives to postgres" if tries > 5
  tries += 1
  sleep(1)
end

# Create roles and permissions
pg = PG.connect(dbname: 'postgres', host: '127.0.0.1', user: 'postgres')
Rake::Task[:init].invoke && execute_build(pg)
pg.close


at_exit do
  postgres_container.stop
  postgres_container.delete
end
