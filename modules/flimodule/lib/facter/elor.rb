# Check to see if this server has been marked as a web server
Facter.add(:role) do
  has_weight 100
  setcode do
    if File.exist? '/etc/httpd'
      'webserver'
    end
  end
end

# If this server doesn't look like a server, it must be a desktop
Facter.add(:role) do
  has_weight 0
  setcode do
    'desktop'
  end
end
