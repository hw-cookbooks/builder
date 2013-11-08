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
      unless(new_resource.creates)
        new_resource.creates @build_dir
      end
      if(self.respond_to?(:builder_load))
        builder_load
      end
    end

    def destroy
      [@build_dir, @packaging_dir].each do |dir|
        directory dir do
          action :delete
        end
      end

      builds = Mash.new(node.set[:builder][:builds].to_hash)
      builds.delete(new_resource.name.to_sym)
      node.set[:builder][:builds] = builds

    end

    def build
      unless(::File.exists?(new_resource.creates))
        begin
          build_dir = @build_dir
          pkg_dir = @packaging_dir

          directory @build_dir do
            recursive true
          end

          if(new_resource.create_packaging_directory)
            directory @packaging_dir do
              action :delete
              recursive true
            end

            directory @packaging_dir do
              recursive true
            end
          end

          yield

          build_resource = new_resource

          new_resource.commands.each do |com|
            if(com.is_a?(String))
              command = com
              com_env = {}
            else
              command = com[:command]
              com_env = com[:environment]
            end
            execute "building(#{command})" do
              command command
              cwd lazy{
                ::File.join(
                  build_resource.custom_cwd || build_dir,
                  build_resource.suffix_cwd || ''
                )
              }
              environment(
                {'PKG_DIR' => pkg_dir}.merge(com_env)
              )
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

        node.set[:builder][:builds][new_resource.name.to_sym][:build_path] = @build_dir
        node.set[:builder][:builds][new_resource.name.to_sym][:expanded_path] = @cwd
        node.set[:builder][:builds][new_resource.name.to_sym][:packaging_path] = @packaging_dir
        node.set[:builder][:builds][new_resource.name.to_sym][:time] = Time.now.to_i

        new_resource.updated_by_last_action(true)
      end
    end
  end
end
