namespace :custom do
  task :copy_env do
    on roles(:web) do
      execute %[cp /var/www/html/Yoshinani/shared/.env /var/www/html/Yoshinani/current]
    end
  end

  before 'deploy:restart', 'custom:copy_env'
end
