include Builder::Provider

action :create do
  build do
    if(new_resource.init_command)
      execute "initialize(#{new_resource.init_command})" do
        command new_resource.init_command
        cwd build_dir
        environment 'PKG_DIR' => pkg_dir
      end
    end
  end
end
