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

File.open('./empty.nothing', 'w')

postgres_container = Docker::Container.create(
  'name' => 'testdb',
  'Image' => ENV['POSTGRES_IMAGE'] || 'ghcr.io/proluceo/proluceo:main',
  'ExposedPorts' => { '5432/tcp' => {} },
  'ENV' => ['POSTGRES_HOST_AUTH_METHOD=trust'],
  'HostConfig' => {
    'Binds' => [
      File.expand_path('./empty.nothing') + ":/docker-entrypoint-initdb.d/schema.sql:ro"
    ],
    'PortBindings' => {
      '5432/tcp' => [{ 'HostPort' => '5432', 'HostIp' => '127.0.0.1' }]
    }
  }
)

postgres_container.start

tries = 0
while PG::Connection.ping(dbname: 'postgres', host: '127.0.0.1', user: 'proluceo') != PG::PQPING_OK do
  raise "Exceeded connections tentatives to postgres" if tries > 5
  tries += 1
  sleep(1)
end

# Create roles and permissions
pg = PG.connect(dbname: 'postgres', host: '127.0.0.1', user: 'proluceo')
Rake::Task[:init].invoke && execute_build(pg)
pg.close


at_exit do
  postgres_container.stop
  postgres_container.delete
end
