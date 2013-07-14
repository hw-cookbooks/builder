include Builder::Provider

action :create do
  build do
    execute "Unpack gem: #{new_resource.gem_name}" do
      command "#{node[:builder][:gem][:exec]} unpack #{new_resource.gem_name}#{" --version #{new_resource.gem_version}" if new_resource.gem_version}"
      cwd build_dir
    end
  end
end
