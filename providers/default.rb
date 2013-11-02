def load_current_resource
  @proxy = if(new_resource.proxy_store.has_key?(:repository))
             :builder_git
           elsif(new_resource.proxy_store.has_key?(:gem_name))
             :builder_gem
           elsif(new_resource.proxy_store.has_key?(:remote_file))
             :builder_remote
           elsif(new_resource.proxy_store.has_key?(:init_command))
             :builder_dir
           else
             raise NameError.new 'Unable to determine builder type for proxy resource generation'
           end
end

action :create do
  self.send(@proxy, new_resource.name) do
    new_resource.proxy_store.each do |k, args|
      self.send(k, *args)
      action :create
    end
  end
end

action :delete do
  self.send(@proxy, new_resource.name) do
    new_resource.proxy_store.each do |k, args|
      self.send(k, *args)
      action :delete
    end
  end
end
