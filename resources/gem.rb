actions :create, :delete
default_action :create

attribute :commands, :kind_of => Array
attribute :custom_cwd, :kind_of => String
attribute :suffix_cwd, :kind_of => String
attribute :create_packaging_directory, :kind_of => [TrueClass,FalseClass], :default => true
attribute :gem_name, :kind_of => String, :required => true
attribute :gem_version, :kind_of => String
attribute :creates, :kind_of => String
