version = Chef::Version.new(Chef::VERSION)
use_inline_resources if version.major >= 11

def load_current_resource
  @build_dir = ::File.join(node[:builder][:build_dir], new_resource.name)
  @packaging_dir = ::File.join(node[:builder][:packaging_dir], new_resource.name)
  @cwd = new_resource.custom_cwd || @build_dir
  @cwd = ::File.join(@cwd, new_resource.suffix_cwd) if new_resource.suffix_cwd
  unless(new_resource.creates)
    new_resource.creates @build_dir
  end
end

action :create do
  unless(::File.exists?(new_resource.creates))
    begin
      build_dir = @build_dir
      pkg_dir = @packaging_dir
      exec_cwd = @cwd

      directory @build_dir do
        recursive true
      end

      if(new_resource.create_packaging_directory)
        directory @packaging_dir do
          recursive true
        end
      end

      git @build_dir do
        repository new_resource.repository
        reference new_resource.reference
        depth 1
      end
   
      new_resource.commands.each do |command|
        execute "building(#{command})" do
          command command
          cwd exec_cwd
          environment 'PKG_DIR' => pkg_dir
        end
      end
    rescue Mixlib::ShellOut::ShellCommandFailed
      Chef::Log.error "Failed to build requested resource! Cleaning up!"
      directory @build_dir do
        action :delete
      end
      if(new_resource.create_packaging_directory && ::File.directory?(@packaging_dir))
        directory @packaging_dir do
          action :delete
        end
      end
      raise
    end
    new_resource.updated_by_last_action(true)
  end
end
