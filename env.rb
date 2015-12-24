class Environment
  attr_accessor :name, :type, :secret, :variables, :instances

  def initialize(opts={})
    @name = opts[:name]
    @type = opts[:type]
    @secret = opts[:secret]
    @variables = Hash.new
    @instances = Array.new
  end

  # add variables
  def add_variable(opts={})
    raise "Keyname and role cannot be the same value" if opts[:keyname] == opts[:role]
    @variables["#{opts[:keyname]}-#{opts[:role]}"] = opts[:value]

    # if the variables role is an instance, add it to the instances array
    if opts[:role].match(/instance/)
      @instances << opts[:value][:ipaddress]
    end
  end

end