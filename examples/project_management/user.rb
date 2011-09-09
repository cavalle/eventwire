self.class.send :remove_const, :User if defined?(User)

class User < Struct.new(:name)
end