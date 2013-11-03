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
  end
end
