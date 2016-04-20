namespace :custom do
  task :copy_env do
    on roles(:web) do
      within release_path do
        execute %[cp /var/www/html/Yoshinani/shared/.env /var/www/html/Yoshinani/current]
      end
    end
  end

  before 'deploy:updated', 'custom:copy_env'
end
