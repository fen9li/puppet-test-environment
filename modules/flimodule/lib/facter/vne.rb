# Return agent enviroment: must be test in this code test context

Facter.add(:env) do
  setcode do
    agent_env = Facter.value("agent_specified_environment")
    if agent_env != nil
      Facter.value("agent_specified_environment").to_s
    end
  end
end

