include ::Builder::Provider

action :create do
  build do
    remote_file ::File.join(@build_dir, ::File.basename(new_resource.remote_file)) do
      source new_resource.remote_file
      action :create_if_missing
    end
    build_dir = @build_dir
    execute "Unpack remote file: #{::File.basename(new_resource.remote_file)}" do
      command "tar -xzf #{::File.basename(new_resource.remote_file)}"
      cwd build_dir
    end
    builder_resource = new_resource
    ruby_block 'Probably the right suffix' do
      block do
        dirs = Dir.glob(::File.join(build_dir, '*'))
        dirs.delete_if do |d|
          !::File.directory?(d)
        end
        dirs.map! do |d|
          d.sub(%r{#{Regexp.escape(build_dir)}/?}, '')
        end
        unless(dirs.size > 1)
          builder_resource.suffix_cwd dirs.first
        end
      end
    end
  end
end
