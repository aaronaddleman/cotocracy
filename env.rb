class Env
  attr_accessor :name, :keyvalue, :secret?

  def initialize(name, keyvalue, secret=false)
    @name = name
    @keyvalue = keyvalue
    @secret = secret
  end
end