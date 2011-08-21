require 'csv'
if CSV.const_defined? :Reader
  require 'fastercsv'
  Object.send(:remove_const, :CSV)
  CSV = FasterCSV
  # CSV is now FasterCSV in ruby 1.9
end
