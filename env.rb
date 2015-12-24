class Environment
  attr_accessor :name, :type, :secret, :variables

  def initialize(opts={})
    @name = opts[:name]
    @type = opts[:type]
    @secret = opts[:secret]
    @variables = Hash.new
  end

  def add_variable(opts={})
    raise "Keyname and role cannot be the same value" if opts[:keyname] == opts[:role]
    @variables["#{opts[:keyname]}-#{opts[:role]}"] = opts[:value]
  end
end