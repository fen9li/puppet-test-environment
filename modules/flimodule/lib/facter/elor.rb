# Check to see if this server has been marked as a web server
Facter.add(:role) do
  setcode do
    if File.exist? '/etc/httpd'
      'webserver'
    end
  end
end

# Check to see if this server has been marked as a elasticsearchnode
Facter.add(:role) do
  setcode do
    if File.exist? '/etc/elasticsearch'
      'elasticsearchnode'
    end
  end
end

# If this server doesn't look like a server, it must be a desktop
Facter.add(:role) do
  setcode do
    'desktop'
  end
end
