self.class.send :remove_const, :TasksStats if defined?(TasksStats)

module TasksStats
  include Eventwire::Subscriber
  
  @completion_time_sum   = 0
  @completion_time_count = 0
  @start_times = {}

  on :task_created do |event|
    @start_times[event.task_name] = Time.parse(event.timestamp.to_s)
  end

  on :task_completed do |event|
    @completion_time_sum   += Time.parse(event.timestamp.to_s) - @start_times.delete(event.task_name)
    @completion_time_count += 1
  end

  def self.average_completion_time
    return -1 if @completion_time_sum == 0
    @completion_time_sum / @completion_time_count
  end
  
end