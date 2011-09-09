self.class.send :remove_const, :Task if defined?(Task)

class Task
  include Eventwire::Publisher
  
  def initialize(name)
    @name = name
    publish_event :task_created, :task_name => @name, :timestamp => Time.now
  end

  def mark_as_complete!(user)
    @completed = true
    publish_event :task_completed, :task_name => @name, :by => user.name, :timestamp => Time.now
  end
end