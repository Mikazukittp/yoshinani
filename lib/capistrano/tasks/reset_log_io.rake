namespace :custom do
  task :reset_log_io do
    on roles(:web) do
      execute %[log.io stop]
      execute %[log.io start]
    end
  end

  before 'deploy:restart', 'custom:reset_log_io'
end