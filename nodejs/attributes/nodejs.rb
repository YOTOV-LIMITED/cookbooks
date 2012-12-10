default[:nodejs][:version] = "v0.8.9"
default[:nodejs][:source_url] = "http://nodejs.org/dist/#{node[:nodejs][:version]}/node-#{node[:nodejs][:version]}-linux-x64.tar.gz"
default[:nodejs][:source_path] = "/usr/local/src"

# node package manager
default[:nodejs][:install_npm] = "yes"

if nodejs[:install_npm] == "yes"
  # and array of package hashes, {:name => "forever", :global => true}
  default[:nodejs][:npm][:packages] = []
end
