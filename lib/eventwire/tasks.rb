namespace :eventwire do
  task :work do
    trap('INT') { Eventwire.stop_worker; exit }
    Eventwire.start_worker
  end
end