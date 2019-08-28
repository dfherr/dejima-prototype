require 'json'
require 'pry'

test_dir = "3peers/boot_all"



module Evaluate

  def self.correct?(peer_groups)
    return false if peer_groups[:run1] != peer_groups[:run2]
    return false if peer_groups[:run1] != peer_groups[:run3]
    true
  end
  
  
  def self.total_messages_sent(metrics)
    messages = {}
    messages[:avg] = 0
    metrics.each do |run, metric|
      messages[run] = 0
      metric.each_value do |peer|
        messages[run] += peer[:messages_sent]
      end
      messages[:avg] += messages[run]
    end
    messages[:avg] = messages[:avg] / metrics.keys.count
    messages
  end

  def self.average_messages_sent(metrics)
    messages = {}
    messages[:avg] = 0
    metrics.each do |run, metric|
      messages[run] = 0
      metric.each_value do |peer|
        messages[run] += peer[:messages_sent]
      end
      messages[run] = messages[run] / metric.keys.count
      messages[:avg] += messages[run]
    end
    messages[:avg] = messages[:avg] / metrics.keys.count
    messages  
  end
  
  def self.total_messages_received(metrics)
    messages = {}
    messages[:avg] = 0
    metrics.each do |run, metric|
      messages[run] = 0
      metric.each_value do |peer|
        messages[run] += peer[:messages_received]
      end
      messages[:avg] += messages[run]
    end
    messages[:avg] = messages[:avg] / metrics.keys.count
    messages  
  end
  
  def self.average_messages_received(metrics)
    messages = {}
    messages[:avg] = 0
    metrics.each do |run, metric|
      messages[run] = 0
      metric.each_value do |peer|
        messages[run] += peer[:messages_received]
      end
      messages[run] = messages[run] / metric.keys.count
      messages[:avg] += messages[run]
    end
    messages[:avg] = messages[:avg] / metrics.keys.count
    messages  
  end
  
  def self.messages_sent_per_type(metrics)
  
  end
  
  def self.messages_received_per_type(metrics)
  
  end
  
  # earliest start timestamp vs last update received timestamp
  def self.total_time_elapsed(metrics)
  
  end
  
  def self.average_detection_time_elapsed(metrics)
  
  end

end

metrics = {
  run1: JSON.parse(File.read(File.expand_path("../#{test_dir}/run1/final_metrics.json",__FILE__)), symbolize_names: true),
  run2: JSON.parse(File.read(File.expand_path("../#{test_dir}/run2/final_metrics.json",__FILE__)), symbolize_names: true),
  run3: JSON.parse(File.read(File.expand_path("../#{test_dir}/run3/final_metrics.json",__FILE__)), symbolize_names: true)
}

peer_groups = {
  run1: JSON.parse(File.read(File.expand_path("../#{test_dir}/run1/peer_groups.json",__FILE__)), symbolize_names: true),
  run2: JSON.parse(File.read(File.expand_path("../#{test_dir}/run2/peer_groups.json",__FILE__)), symbolize_names: true),
  run3: JSON.parse(File.read(File.expand_path("../#{test_dir}/run3/peer_groups.json",__FILE__)), symbolize_names: true)
}

puts "Correct?: #{Evaluate.correct?(peer_groups)}"
puts "Total messages sent: #{Evaluate.total_messages_sent(metrics)}"
puts "Average messages sent: #{Evaluate.average_messages_sent(metrics)}"
puts "Total messages received: #{Evaluate.total_messages_received(metrics)}"