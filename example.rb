require 'json'
require_relative 'shark_report'

report = ProbeReport::Report.new('sample_data.txt')

File.open('report.json', 'w') do |f|
  f.write(report.to_hash.to_json)
end

File.open('report.tsv', 'w') do |f|
  f.write(report.to_tsv)
end
