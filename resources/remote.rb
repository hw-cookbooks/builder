actions :create, :delete
default_action :create

attribute :commands, :kind_of => Array
attribute :custom_cwd, :kind_of => String
attribute :suffix_cwd, :kind_of => String
attribute :create_packaging_directory, :kind_of => [TrueClass,FalseClass], :default => true
attribute :creates, :kind_of => String
attribute :remote_file, :kind_of => String, :required => true
