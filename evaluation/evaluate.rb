require 'json'
require 'pry'
require 'time'

test_dir = "3peers/boot_all"



module Evaluate

  def self.correct?(peer_groups)
    return false if peer_groups[:run1] != peer_groups[:run2]
    return false if peer_groups[:run1] != peer_groups[:run3]
    true
  end
  
  
  def self.total_count(metrics, key)
    messages = {}
    messages[:avg] = 0
    metrics.each do |run, metric|
      messages[run] = 0
      metric.each_value do |peer|
        messages[run] += peer[key]
      end
      messages[:avg] += messages[run]
    end
    messages[:avg] = messages[:avg] * 1.0 / metrics.keys.count
    messages
  end

  def self.average_count(metrics, key)
    messages = {}
    messages[:avg] = 0
    metrics.each do |run, metric|
      messages[run] = 0
      metric.each_value do |peer|
        messages[run] += peer[key]
      end
      messages[run] = messages[run] * 1.0 / metric.keys.count
      messages[:avg] += messages[run]
    end
    messages[:avg] = messages[:avg] * 1.0 / metrics.keys.count
    messages  
  end
  
  def self.total_count_per_type(metrics, key)
    messages = {}
    messages[:avg] = {
      insurance: 0,
      government: 0,
      bank: 0
    }
    metrics.each do |run, metric|
      messages[run] = {}
      metric.each do |instance, peer|
        messages[run][get_type(instance)] ||= 0
        messages[run][get_type(instance)] += peer[key]
      end
      messages[:avg][:government] += messages[run][:government] * 1.0
      messages[:avg][:bank] += messages[run][:bank] * 1.0
      messages[:avg][:insurance] += messages[run][:insurance] * 1.0
    end
    messages[:avg][:government] = messages[:avg][:government] * 1.0 / metrics.keys.count
    messages[:avg][:bank] = messages[:avg][:bank] * 1.0 / metrics.keys.count
    messages[:avg][:insurance] = messages[:avg][:insurance] * 1.0 / metrics.keys.count
    messages
  end

  def self.average_count_per_type(metrics, key)
    messages = {}
    messages[:avg] = {
      insurance: 0,
      government: 0,
      bank: 0
    }
    type_count = {
      insurance: 0,
      government: 0,
      bank: 0
    }
    metrics[:run1].each_key do |instance|
      type_count[get_type(instance)] += 1
    end
    metrics.each do |run, metric|
      messages[run] = {}
      metric.each do |instance, peer|
        messages[run][get_type(instance)] ||= 0
        messages[run][get_type(instance)] += peer[key]
      end
      # average run
      messages[run][:government] = messages[run][:government]  * 1.0 / type_count[:government]
      messages[run][:bank] = messages[run][:bank] * 1.0 / type_count[:bank]
      messages[run][:insurance] = messages[run][:insurance] * 1.0 / type_count[:insurance]
      # add tot toal average
      messages[:avg][:government] += messages[run][:government] * 1.0
      messages[:avg][:bank] += messages[run][:bank] * 1.0
      messages[:avg][:insurance] += messages[run][:insurance] * 1.0
    end
    messages[:avg][:government] = messages[:avg][:government] * 1.0 / metrics.keys.count
    messages[:avg][:bank] = messages[:avg][:bank] * 1.0 / metrics.keys.count
    messages[:avg][:insurance] = messages[:avg][:insurance] * 1.0 / metrics.keys.count
    messages
  end
  
  def self.average_detection_time_elapsed(metrics)
    detection_time = {}
    detection_time[:avg] = 0
    metrics.each do |run, metric|
      detection_time[run] = 0
      metric.each_value do |peer|
        time_elapsed = Time.parse(peer[:detection_finished]) - Time.parse(peer[:detection_started])
        detection_time[run] += time_elapsed
      end
      detection_time[run] = detection_time[run] * 1.0 / metric.keys.count
      detection_time[:avg] += detection_time[run]
    end
    detection_time[:avg] = detection_time[:avg] * 1.0 / metrics.keys.count
    detection_time
  end

  def self.average_detection_time_elapsed_per_type(metrics)
    detection_time = {}
    detection_time[:avg] = {
      insurance: 0,
      government: 0,
      bank: 0
    }
    type_count = {
      insurance: 0,
      government: 0,
      bank: 0
    }
    metrics[:run1].each_key do |instance|
      type_count[get_type(instance)] += 1
    end
    metrics.each do |run, metric|
      detection_time[run] = {}
      metric.each do |instance, peer|
        time_elapsed = Time.parse(peer[:detection_finished]) - Time.parse(peer[:detection_started])
        detection_time[run][get_type(instance)] ||= 0
        detection_time[run][get_type(instance)] += time_elapsed
      end
      # average run
      detection_time[run][:government] = detection_time[run][:government]  * 1.0 / type_count[:government]
      detection_time[run][:bank] = detection_time[run][:bank] * 1.0 / type_count[:bank]
      detection_time[run][:insurance] = detection_time[run][:insurance] * 1.0 / type_count[:insurance]
      # add tot toal average
      detection_time[:avg][:government] += detection_time[run][:government] * 1.0
      detection_time[:avg][:bank] += detection_time[run][:bank] * 1.0
      detection_time[:avg][:insurance] += detection_time[run][:insurance] * 1.0
    end
    detection_time[:avg][:government] = detection_time[:avg][:government] * 1.0 / metrics.keys.count
    detection_time[:avg][:bank] = detection_time[:avg][:bank] * 1.0 / metrics.keys.count
    detection_time[:avg][:insurance] = detection_time[:avg][:insurance] * 1.0 / metrics.keys.count
    detection_time
  end

  # detection start vs last update received timestamp or broadcast sent (whatever is later)
  # this metric is only useful for boot all tests.
  def self.average_time_elapsed(metrics)
    detection_time = {}
    detection_time[:avg] = 0
    metrics.each do |run, metric|
      detection_time[run] = 0
      metric.each_value do |peer|
        # one of both is always not null
        last_broadcast = Time.parse(peer[:last_broadcast] || "2018-01-01T00:00:00")
        last_update_request_received = Time.parse(peer[:last_update_request_received] || "2018-01-01T00:00:00")
        time_finished = last_broadcast > last_update_request_received ? last_broadcast : last_update_request_received
        time_elapsed =  time_finished - Time.parse(peer[:detection_started])
        detection_time[run] += time_elapsed
      end
      detection_time[run] = detection_time[run] * 1.0 / metric.keys.count
      detection_time[:avg] += detection_time[run]
    end
    detection_time[:avg] = detection_time[:avg] * 1.0 / metrics.keys.count
    detection_time  
  end

  def self.average_time_elapsed_per_type(metrics)
    detection_time = {}
    detection_time[:avg] = {
      insurance: 0,
      government: 0,
      bank: 0
    }
    type_count = {
      insurance: 0,
      government: 0,
      bank: 0
    }
    metrics[:run1].each_key do |instance|
      type_count[get_type(instance)] += 1
    end
    metrics.each do |run, metric|
      detection_time[run] = {}
      metric.each do |instance, peer|
        # one of both is always not null
        last_broadcast = Time.parse(peer[:last_broadcast] || "2018-01-01T00:00:00")
        last_update_request_received = Time.parse(peer[:last_update_request_received] || "2018-01-01T00:00:00")
        time_finished = last_broadcast > last_update_request_received ? last_broadcast : last_update_request_received
        time_elapsed =  time_finished - Time.parse(peer[:detection_started])
        detection_time[run][get_type(instance)] ||= 0
        detection_time[run][get_type(instance)] += time_elapsed
      end
      # average run
      detection_time[run][:government] = detection_time[run][:government]  * 1.0 / type_count[:government]
      detection_time[run][:bank] = detection_time[run][:bank] * 1.0 / type_count[:bank]
      detection_time[run][:insurance] = detection_time[run][:insurance] * 1.0 / type_count[:insurance]
      # add tot toal average
      detection_time[:avg][:government] += detection_time[run][:government] * 1.0
      detection_time[:avg][:bank] += detection_time[run][:bank] * 1.0
      detection_time[:avg][:insurance] += detection_time[run][:insurance] * 1.0
    end
    detection_time[:avg][:government] = detection_time[:avg][:government] * 1.0 / metrics.keys.count
    detection_time[:avg][:bank] = detection_time[:avg][:bank] * 1.0 / metrics.keys.count
    detection_time[:avg][:insurance] = detection_time[:avg][:insurance] * 1.0 / metrics.keys.count
    detection_time
  end

  # get type from instance
  def self.get_type(instance)
    instance.to_s.gsub(/\d/,'').to_sym
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
puts "\n"

puts "#### messages sent ####"
puts "Total messages sent:\n #{Evaluate.total_count(metrics, :messages_sent)}"
puts "Average messages sent:\n #{Evaluate.average_count(metrics, :messages_sent)}"
puts "Total messages sent per type:\n #{Evaluate.total_count_per_type(metrics, :messages_sent)}"
puts "Average messages sent per type:\n #{Evaluate.average_count_per_type(metrics, :messages_sent)}"
puts "\n"

puts "#### messages received ####"
puts "Total messages received:\n #{Evaluate.total_count(metrics, :messages_received)}"
puts "Average messages received:\n #{Evaluate.average_count(metrics, :messages_received)}"
puts "Total messages received per type:\n #{Evaluate.total_count_per_type(metrics, :messages_received)}"
puts "Average messages received per type:\n #{Evaluate.average_count_per_type(metrics, :messages_received)}"
puts "\n"

puts "#### broadcasts ####"
puts "Total broadcasts:\n #{Evaluate.total_count(metrics, :broadcast_count)}"
puts "Average broadcasts:\n #{Evaluate.average_count(metrics, :broadcast_count)}"
puts "Total broadcasts per type:\n #{Evaluate.total_count_per_type(metrics, :broadcast_count)}"
puts "Average broadcasts per type:\n #{Evaluate.average_count_per_type(metrics, :broadcast_count)}"
puts "\n"

puts "#### update requests received ####"
puts "Total update requests received:\n #{Evaluate.total_count(metrics, :update_request_count)}"
puts "Average update requests received:\n #{Evaluate.average_count(metrics, :update_request_count)}"
puts "Total update requests received per type:\n #{Evaluate.total_count_per_type(metrics, :update_request_count)}"
puts "Average update requests received per type:\n #{Evaluate.average_count_per_type(metrics, :update_request_count)}"
puts "\n"

puts "#### update request conflicts ####"
puts "Total update request conflicts:\n #{Evaluate.total_count(metrics, :update_request_conflict_count)}"
puts "Average update request conflicts:\n #{Evaluate.average_count(metrics, :update_request_conflict_count)}"
puts "Total update request conflicts per type:\n #{Evaluate.total_count_per_type(metrics, :update_request_conflict_count)}"
puts "Average update request conflicts per type:\n #{Evaluate.average_count_per_type(metrics, :update_request_conflict_count)}"
puts "\n"

puts "#### Time metrics ####"
puts "Average detection time:\n #{Evaluate.average_detection_time_elapsed(metrics)}"
puts "Average detection time per type:\n #{Evaluate.average_detection_time_elapsed_per_type(metrics)}"
puts "Average time elapsed:\n #{Evaluate.average_time_elapsed(metrics)}"
puts "Average time elapsed per type:\n #{Evaluate.average_time_elapsed_per_type(metrics)}"