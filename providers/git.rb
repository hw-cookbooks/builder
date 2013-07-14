include Builder::Provider

action :create do
  build do
    git @build_dir do
      repository new_resource.repository
      reference new_resource.reference
      depth 1
    end
  end
end
