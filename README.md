# Builder

A helper cookbooks for building things with Chef

## Usage

Provides LWRPs to help DRY building things with Chef. 

## Attributes

* default[:builder][:build_dir] = '/usr/src/builder/sources'
* default[:builder][:packaging_dir] = '/usr/src/builder/packaging'
* default[:builder][:gem][:exec] = node[:languages][:ruby][:gem_bin]

## LWRPs

### builder_dir

```
builder_dir 'customapp-1.0.tar.gz' do
  remote_file 'http://example.com/downloads/customapp-1.0.tar.gz'
  suffix_cwd 'customapp-1.0'
  commands [
    './configure',
    'make install DESTDIR=$PKG_DIR'
  ]
end

The $PKG_DIR is an environment variable that will be available to
build commands. The $PKG_DIR is created by the LWRP to provide a
location to install files for later packaging.

## Infos
* Repository: http://github.com/hw-cookbooks/builder
* IRC: Freenode @ #heavywater
