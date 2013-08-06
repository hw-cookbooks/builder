include Builder::Provider

def load_current_resource
#  new_resource.reference %x{git ls-remote #{new_resource.repository} #{new_resource.reference}}.split.first.strip
  @build_dir = ::File.join(node[:builder][:build_dir], new_resource.name, new_resource.reference)
  @packaging_dir = ::File.join(node[:builder][:packaging_dir], new_resource.name, new_resource.reference)
  @cwd = new_resource.custom_cwd || @build_dir
  @cwd = ::File.join(@cwd, new_resource.suffix_cwd) if new_resource.suffix_cwd
  unless(new_resource.creates)
    new_resource.creates @build_dir
  end
end

action :create do

  # TODO: Infer from repo
  ssh_known_hosts_entry 'github.com'
  
  build do

    package 'git'
    
    git @build_dir do
      repository new_resource.repository
      reference new_resource.reference
      depth 1
    end
  end
end
