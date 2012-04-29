# encoding: UTF-8
require 'spec_helper'

describe 'Project Management System' do

  adapters = %w{InProcess AMQP Redis Mongo}

  adapters.each do |adapter|

    with_adapter adapter do

      before do
        Eventwire.configure do |c|
          c.adapter = adapter
          c.logger = Logger.new(nil)
        end

        load_environment
        start_worker

        @jdoe = User.new('jdoe')
        @rroe = User.new('rroe')

        @task1 = time_travel_to(10.minutes.ago) { Task.new('Do some work') }
        @task2 = time_travel_to(20.minutes.ago) { Task.new('Do more work') }
      end

      after do
        stop_worker
        purge
      end

      example 'Completing tasks should update stats' do
        @task1.mark_as_complete! @jdoe
        @task2.mark_as_complete! @rroe

        eventually do
          TasksStats.average_completion_time.should be_within(1.second).of(15.minutes)
        end
      end

      example 'Completing tasks should notify bosses' do
        Notifier.sent_emails.clear

        @task1.mark_as_complete! @jdoe
        @task2.mark_as_complete! @rroe

        eventually do
          Notifier.should have(2).sent_emails
          Notifier.sent_emails.should include(:email => 'boss_of_jdoe@corp.net', :subject => 'Task Do some work completed')
          Notifier.sent_emails.should include(:email => 'boss_of_rroe@corp.net', :subject => 'Task Do more work completed')
        end
      end

    end

  end

  private

  def start_worker
    @t = Thread.new { 
      require 'rake'
      require 'eventwire/tasks'
      
      Rake::Task['eventwire:work'].execute 
    }
    @t.abort_on_exception = true
    sleep 0.1
  end

  def load_environment
    load 'examples/project_management/user.rb'
    load 'examples/project_management/task.rb'
    load 'examples/project_management/tasks_stats.rb'
    load 'examples/project_management/notifier.rb'
  end

  def stop_worker
    return unless @t.alive?
    
    Eventwire.stop_worker
    
    @t.join(1)
    fail 'Worker should have stopped' if @t.alive?
    @t.kill # even if not alive, it seems that in 1.8.7 we need to kill it
  end
  
  def purge
    Eventwire.driver.purge
  end

end
