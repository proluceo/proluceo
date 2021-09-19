require 'rake/clean'
require 'pathname'
require 'json'
require 'fileutils'
require 'erb'

SRC_PATH = Pathname.new('src')
TMP_PATH = Pathname.new('tmp')
BUILD_PATH = Pathname.new('build')

CLEAN.add("#{TMP_PATH}/*.sql")
CLEAN.add("#{BUILD_PATH}/schema.sql")

@sequence = 0
def add_source(filepath)
  puts "Adding #{filepath}"
  filename = filepath.each_filename.to_a.join('_')
  FileUtils.ln_s(filepath.relative_path_from(TMP_PATH), TMP_PATH + "#{@sequence.to_s.rjust(10,'0')}-#{filename}")
  @sequence += 1
end

def create_task_with_deps(path)
  task_fqn = ""
  if path.file? and path.extname == '.sql'
    filepath_wo_ext = Pathname.new(path.relative_path_from(SRC_PATH).to_s[..-5])
    task_fqn = filepath_wo_ext.each_filename.to_a.join(':')
    if Rake::Task.task_defined?(task_fqn)
      #puts "Task #{task_fqn} already exists. Skipping"
      return task_fqn
    end

    deps_fqn = []
    # Always add schema to deps
    nodes = task_fqn.split(':')
    if nodes[0] == 'schemas' && nodes.size > 2
      schema_name = nodes[1]
      deps_fqn << ['schemas', schema_name].join(':') unless schema_name == 'public'
    end

    # Parse deps metadata
    File.open(path) do |f|
      matches = /-- depends_on: (\[.*\])/.match(f.gets)
      if !matches.nil?
        dependencies = JSON.parse(matches[1])
        deps_fqn = dependencies.map do |dep|
          dep_path = File.join(dep.split(':'))
          base_path = if dep[0..1] == '::'
            SRC_PATH
          else
            path.dirname
          end
          dep_fullpath = Pathname.new(File.join(base_path,dep.split(':').reject(&:empty?)) + '.sql')
          if !dep_fullpath.exist?
            raise "Cannot find dependency #{dep_fullpath}"
          end
          create_task_with_deps(dep_fullpath)
        end
      end
    end
    t = Rake::Task.define_task(task_fqn.to_sym => deps_fqn) do
      add_source(path)
    end
    #puts "Defined task '#{t}' with deps #{deps_fqn}"

  elsif path.directory?
    task_fqn = path.relative_path_from(SRC_PATH).each_filename.to_a.join(':')
    task_fqn += ':all'
    if Rake::Task.task_defined?(task_fqn)
      #puts "Task #{task_fqn} already exists. Skipping"
      return task_fqn
    end
    # Create files tasks first
    deps = path.children.select(&:file?).map { |child| create_task_with_deps(child) }
    deps += path.children.select(&:directory?).map { |child| create_task_with_deps(child) }
    t = Rake::Task.define_task(task_fqn.to_sym => deps)
    #puts "Defined task '#{t}' with deps #{deps}"
  else
    #puts "Ignoring file #{path}"
  end

  return task_fqn
end

directory TMP_PATH
directory BUILD_PATH
SRC_PATH.each_child { |child| create_task_with_deps(child) }

file 'schema.sql' => [:build] do
  sh "cat #{TMP_PATH}/* > #{BUILD_PATH}/schema.sql"
  rm Dir.glob("#{TMP_PATH}/*")
  @sequence = 0
end


## Testing
def generate_cucumber_features
  FileUtils.rm_r('features/schemas')
  Rake::Task.tasks().each do |task|
    nodes = task.name.split(':')
    if nodes.include?('tables')
      table_name= nodes[-1]
      next if table_name == 'all'
      schema_name = nodes[1]

      template = ERB.new(File.read(File.join('features', 'templates', 'table.feature.erb')))
      dirpath = FileUtils.mkpath(File.join(['features'] + nodes[0..-2]))
      File.open(File.join(dirpath, table_name + '.feature'), 'w') { |f| f.write(template.result(binding)) }
    end
  end
end

task :cucumber do
  generate_cucumber_features
end

task init: [:clean, :tmp, :"roles:all"]
task complete: [:init, :"schemas:all", :"permissions", 'schema.sql']
task default: [:complete]

