actions :create, :delete
default_action :create

attr_reader :proxy_store

def method_missing(*args)
  @proxy_store ||= Mash.new
  @proxy_store[args.first] = args[1, args.size]
end
