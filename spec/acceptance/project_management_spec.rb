require 'spec_helper'

describe 'Project Management System' do  

  before do
    Eventwire.driver = :InProcess
    
    load 'examples/project_management/user.rb'
    load 'examples/project_management/task.rb'
    load 'examples/project_management/tasks_stats.rb'
    load 'examples/project_management/notifier.rb'
    
    @jdoe = User.new('jdoe')
    @rroe = User.new('rroe')
    
    @task1 = time_travel_to(10.minutes.ago) { Task.new('Do some work') }
    @task2 = time_travel_to(20.minutes.ago) { Task.new('Do more work') }
  end
  
  example 'Completing tasks should update stats' do
    @task1.mark_as_complete! @jdoe
    @task2.mark_as_complete! @rroe
    
    TasksStats.average_completion_time.should == 15.minutes
  end
  
  example 'Completing tasks should notify bosses' do
    Notifier.sent_emails.clear
    
    @task1.mark_as_complete! @jdoe
    @task2.mark_as_complete! @rroe
    
    Notifier.should have(2).sent_emails
    Notifier.sent_emails.should include(:email => 'boss_of_jdoe@corp.net', :subject => 'Task Do some work completed')
    Notifier.sent_emails.should include(:email => 'boss_of_rroe@corp.net', :subject => 'Task Do more work completed')
  end
  
end