class Notifier
  include Eventwire::Subscriber

  on :task_completed do |event|
    Notifier.new(:email   => find_boss_email(event.by), 
                 :subject => "Task #{event.task_name} completed").send!
  end
  
  def initialize(email)
    @email = email
  end
  
  def self.find_boss_email(name)
    "boss_of_#{name}@corp.net"
  end
  
  cattr_accessor :sent_emails
  self.sent_emails = []
  
  def send!
    sent_emails << @email
  end

end