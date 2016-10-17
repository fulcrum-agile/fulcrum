# config/puma.rb
 threads 1, 15
 workers 1

 on_worker_boot do
   # things workers do
 end
