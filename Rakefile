require 'rake/clean'
require 'pathname'
require 'json'

SRC_PATH = Pathname.new('./src')
TMP_PATH = Pathname.new('./tmp')
CLEAN.add('tmp/*.sql')
CLEAN.add('schema.sql')

@sequence = 0
def add_source(filepath)
  puts "Adding #{filepath}"
  filename = filepath.each_filename.to_a.join('_')
  FileUtils.ln_s(filepath.relative_path_from(TMP_PATH), TMP_PATH + "#{@sequence}-#{filename}")
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
    #Rake::Task.define_task(task_fqn, deps)
    t = Rake::Task.define_task(task_fqn.to_sym => deps)
    #puts "Defined task '#{t}' with deps #{deps}"
  else
    puts "Ignoring file #{path}"
  end

  return task_fqn
end

directory 'tmp'
SRC_PATH.each_child { |child| create_task_with_deps(child) }

file 'schema.sql' do
  sh "cat #{TMP_PATH}/* > schema.sql"
end

task complete: [:clean, :tmp, :"roles:all", :"schemas:all", :"permissions", 'schema.sql']
task default: [:complete]

