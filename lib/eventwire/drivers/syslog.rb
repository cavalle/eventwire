require 'eventmachine'
require 'syslog_protocol'

# SYSLOG DRIVER
#
# Syslog driver allows using the standard syslog as a queue.
#
# By default writes to the local machine to the port 514 where usually listen
# programs like rsyslog or syslog-ng. That program could send the logs to other
# machines.
#
# By default Syslog uses facility *local0* so you can use that facility to say
# to the syslog daemon where to send that messages
#
# The severity by default is *notice*.
#
# In the other machine, you can run the worker that by default will listen in
# port 514 (syslog port). If you want your worker to not run as a privileged
# daemon, you should use other port (> 1024) and say to the syslog daemon to
# forward messages to your port.
#
# By default syslog listen and writes in 127.0.0.1
#
# ADVANTAGES
#
#   * Probably the fastest ways to send messages
#
# DISADVANTAGES
#
#   * No confirmation
#   * Only one program can listen in one port at the same time (as far as I know)
#   * Have a few limitations
#
# LIMITATIONS
#
#   * The syslog protocol only allows packets of 1024 bytes so the message
#     should be short enough. In that packet will go a timestamp, facillity,
#     severity, hostname, and message.
#   * Only the key *content* of the hash passed to _publish_ will be transmited.
#     The rest of the keys will be silently ignored.
#
# @example Creation
#   options = {}
#   Syslog.new(options)
#
# And the options that chould be changes are:
#
#   DEFAULT_OPTIONS = {
#     :subscriber_listen_port         => '514',
#     :subscriber_listen_interface    => '127.0.0.1',
#     :publisher_destination_host => '127.0.0.1',
#     :publisher_destination_port => '514',
#     :facility                   => 'local0',
#     :severity                   => 'notice',
#     :hostname                   => `hostname`.strip
#   }
#
# EXTRAS
#
# The syslog protocol send messages with a little more information. You can access
# that information when receiving a packet:
#
# @example Extras
#   class Notifier
#     include Eventwire::Subscriber
#
#     on :task_completed do |event|
#       event.facility #=> 16
#       event.severity #=> 5
#       event.hostname #=> the hostname of the maching that send the event
#       event.tag      #=> "task_completed"
#       event.time     #=> an instance of Time with the time the event was generated
#       event.content  #=> the content send with publish
#     end
#   end
#
# RSYSLOG CHEATSHEET
#
# If you want a server to listen in certain port, you should add to rsyslog.conf
#
#   $ModLoad imudp    # Load udp module
#   $UDPServerRun 514 # And listen on port 514
#
# If you want to fordware messages to other machine:
#
#   *.* @www.google.com
#
# If you want to forward messages from another port of the current machine
#
#   *.* @localhost:5514
#
class Eventwire::Drivers::Syslog #:nodoc: all
  include SyslogProtocol

  @@handlers = {}


  DEFAULT_OPTIONS = {
    :subscriber_listen_port      => '514',
    :subscriber_listen_interface => '127.0.0.1',
    :publisher_destination_host  => '127.0.0.1',
    :publisher_destination_port  => '514',
    :facility                    => 'local0',
    :severity                    => 'notice',
    :hostname                    => `hostname`.strip
  }

  class SysLogConnection < ::EventMachine::Connection
    def receive_data(data)
      packet = SyslogProtocol.parse(data)
      ::Eventwire::Drivers::Syslog.handlers(packet.tag).each do |handler|
        message = {
          :content  => packet.content,
          :facility => packet.facility,
          :severity => packet.severity,
          :hostname => packet.hostname,
          :tag      => packet.tag,
          :time     => packet.time
        }
        handler.call(message)
      end
    end
  end

  def initialize(options = {})
    @options = DEFAULT_OPTIONS.merge(options)
  end

  def self.handlers(event_name)
    @@handlers[event_name.to_s] ||= []
  end

  def handlers(event_name)
    self.class.handlers(event_name)
  end

  def publish(event_name, event_data = nil)
    packet          = Packet.new
    packet.tag      = event_name.to_s
    packet.severity = @options[:severity]
    packet.facility = @options[:facility]
    packet.hostname = @options[:hostname]
    packet.content  = event_data && event_data[:content]

    host = @options[:publisher_destination_host]
    port = @options [:publisher_destination_port]

    UDPSocket.new.send packet.to_s, 0, host, port
  end

  def subscribe(event_name, handler_id, &handler)
    handlers(event_name) << handler
  end

  def start
    EventMachine.run do
      interface = @options[:subscriber_listen_interface]
      port = @options[:subscriber_listen_port]

      EventMachine::open_datagram_socket(interface, port , SysLogConnection)
    end
  end

  def stop
    ::EventMachine.stop if EventMachine.reactor_running?
  end

  def purge
  end
end




