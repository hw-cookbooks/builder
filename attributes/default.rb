default[:builder][:build_dir] = '/usr/src/builder/sources'
default[:builder][:packaging_dir] = '/usr/src/builder/packaging'
default[:builder][:gem][:exec] = node[:languages][:ruby][:gem_bin]
