namespace :eventwire do
  task :work do
    trap('INT') { Eventwire.stop_worker }
    Eventwire.start_worker
  end
end