module Builder
  module Resource
    class << self
      def included(klass)
        klass.class_eval do
          actions :create, :delete
          default_action :create

          attribute :commands, :kind_of => Array
          attribute :custom_cwd, :kind_of => String
          attribute :suffix_cwd, :kind_of => String
          attribute :create_packaging_directory, :kind_of => [TrueClass,FalseClass], :default => true
          attribute :creates, :kind_of => String
        end
      end
    end
  end
  module Provider

    class << self

      def included(klass)
        klass.class_eval do
          action :delete do
            destroy
          end
        end
      end
      
    end
    
    def load_current_resource
      @build_dir = ::File.join(node[:builder][:build_dir], new_resource.name)
      @packaging_dir = ::File.join(node[:builder][:packaging_dir], new_resource.name)
      @cwd = new_resource.custom_cwd || @build_dir
      @cwd = ::File.join(@cwd, new_resource.suffix_cwd) if new_resource.suffix_cwd
      unless(new_resource.creates)
        new_resource.creates @build_dir
      end
    end

    def destroy
      [@build_dir, @packaging_dir].each do |dir|
        directory dir do
          action :delete
        end
      end
    end
    
    def build
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

          yield
          
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
  end
end
