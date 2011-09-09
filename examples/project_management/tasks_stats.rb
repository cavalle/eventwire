self.class.send :remove_const, :TasksStats if defined?(TasksStats)

module TasksStats
  include Eventwire::Subscriber
  
  @completion_time_sum   = 0
  @completion_time_count = 0
  @start_times = {}

  on :task_created do |event|
    @start_times[event.task_name] = Time.now
  end

  on :task_completed do |event|
    @completion_time_sum   += Time.now - @start_times.delete(event.task_name)
    @completion_time_count += 1
  end

  def self.average_completion_time
    @completion_time_sum.to_i / @completion_time_count
  end
  
end