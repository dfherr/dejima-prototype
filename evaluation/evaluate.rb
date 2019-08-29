require 'json'
require 'pry'
require 'time'

raise StandardError.new("Please provide the test subdirectory") unless ARGV[0]
test_dir = ARGV[0]

module Evaluate

  def self.correct?(peer_groups)
    return false if peer_groups[:fixture] != peer_groups[:run1]
    return false if peer_groups[:fixture] != peer_groups[:run2]
    return false if peer_groups[:fixture] != peer_groups[:run3]
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
    messages[:avg] = (messages[:avg] * 1.0 / metrics.keys.count).round(4)
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
      messages[run] = (messages[run] * 1.0 / metric.keys.count).round(4)
      messages[:avg] += messages[run]
    end
    messages[:avg] = (messages[:avg] * 1.0 / metrics.keys.count).round(4)
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
    messages[:avg][:government] = (messages[:avg][:government] * 1.0 / metrics.keys.count).round(4)
    messages[:avg][:bank] = (messages[:avg][:bank] * 1.0 / metrics.keys.count).round(4)
    messages[:avg][:insurance] = (messages[:avg][:insurance] * 1.0 / metrics.keys.count).round(4)
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
      messages[run][:government] = (messages[run][:government]  * 1.0 / type_count[:government]).round(4)
      messages[run][:bank] = (messages[run][:bank] * 1.0 / type_count[:bank]).round(4)
      messages[run][:insurance] = (messages[run][:insurance] * 1.0 / type_count[:insurance]).round(4)
      # add tot toal average
      messages[:avg][:government] += messages[run][:government] * 1.0
      messages[:avg][:bank] += messages[run][:bank] * 1.0
      messages[:avg][:insurance] += messages[run][:insurance] * 1.0
    end
    messages[:avg][:government] = (messages[:avg][:government] * 1.0 / metrics.keys.count).round(4)
    messages[:avg][:bank] = (messages[:avg][:bank] * 1.0 / metrics.keys.count).round(4)
    messages[:avg][:insurance] = (messages[:avg][:insurance] * 1.0 / metrics.keys.count).round(4)
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
      detection_time[run] = (detection_time[run] * 1.0 / metric.keys.count).round(4)
      detection_time[:avg] += detection_time[run]
    end
    detection_time[:avg] = (detection_time[:avg] * 1.0 / metrics.keys.count).round(4)
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
      detection_time[run][:government] = (detection_time[run][:government]  * 1.0 / type_count[:government]).round(4)
      detection_time[run][:bank] = (detection_time[run][:bank] * 1.0 / type_count[:bank]).round(4)
      detection_time[run][:insurance] = (detection_time[run][:insurance] * 1.0 / type_count[:insurance]).round(4)
      # add tot toal average
      detection_time[:avg][:government] += detection_time[run][:government] * 1.0
      detection_time[:avg][:bank] += detection_time[run][:bank] * 1.0
      detection_time[:avg][:insurance] += detection_time[run][:insurance] * 1.0
    end
    detection_time[:avg][:government] = (detection_time[:avg][:government] * 1.0 / metrics.keys.count).round(4)
    detection_time[:avg][:bank] = (detection_time[:avg][:bank] * 1.0 / metrics.keys.count).round(4)
    detection_time[:avg][:insurance] = (detection_time[:avg][:insurance] * 1.0 / metrics.keys.count).round(4)
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
      detection_time[run] = (detection_time[run] * 1.0 / metric.keys.count).round(4)
      detection_time[:avg] += detection_time[run]
    end
    detection_time[:avg] = (detection_time[:avg] * 1.0 / metrics.keys.count).round(4)
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
      detection_time[run][:government] = (detection_time[run][:government]  * 1.0 / type_count[:government]).round(4)
      detection_time[run][:bank] = (detection_time[run][:bank] * 1.0 / type_count[:bank]).round(4)
      detection_time[run][:insurance] = (detection_time[run][:insurance] * 1.0 / type_count[:insurance]).round(4)
      # add tot toal average
      detection_time[:avg][:government] += detection_time[run][:government] * 1.0
      detection_time[:avg][:bank] += detection_time[run][:bank] * 1.0
      detection_time[:avg][:insurance] += detection_time[run][:insurance] * 1.0
    end
    detection_time[:avg][:government] = (detection_time[:avg][:government] * 1.0 / metrics.keys.count).round(4)
    detection_time[:avg][:bank] = (detection_time[:avg][:bank] * 1.0 / metrics.keys.count).round(4)
    detection_time[:avg][:insurance] = (detection_time[:avg][:insurance] * 1.0 / metrics.keys.count).round(4)
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
  fixture: JSON.parse(File.read(File.expand_path("../#{test_dir}/peer_groups_fixture.json",__FILE__)), symbolize_names: true),
  run1: JSON.parse(File.read(File.expand_path("../#{test_dir}/run1/peer_groups.json",__FILE__)), symbolize_names: true),
  run2: JSON.parse(File.read(File.expand_path("../#{test_dir}/run2/peer_groups.json",__FILE__)), symbolize_names: true),
  run3: JSON.parse(File.read(File.expand_path("../#{test_dir}/run3/peer_groups.json",__FILE__)), symbolize_names: true)
}

results = {}
results[:correctness] = Evaluate.correct?(peer_groups)

results[:total_messages_sent] = Evaluate.total_count(metrics, :messages_sent)
results[:average_messages_sent] = Evaluate.average_count(metrics, :messages_sent)
results[:total_messages_sent_per_type] = Evaluate.total_count_per_type(metrics, :messages_sent)
results[:average_messages_sent_per_type] = Evaluate.total_count_per_type(metrics, :messages_sent)

results[:total_messages_received] = Evaluate.total_count(metrics, :messages_received)
results[:average_messages_received] = Evaluate.average_count(metrics, :messages_received)
results[:total_messages_received_per_type] = Evaluate.total_count_per_type(metrics, :messages_received)
results[:average_messages_received_per_type] = Evaluate.total_count_per_type(metrics, :messages_received)

results[:total_broadcasts] = Evaluate.total_count(metrics, :broadcast_count)
results[:average_broadcasts] = Evaluate.average_count(metrics, :broadcast_count)
results[:total_broadcasts_per_type] = Evaluate.total_count_per_type(metrics, :broadcast_count)
results[:average_broadcasts_per_type] = Evaluate.total_count_per_type(metrics, :broadcast_count)

results[:total_update_requests] = Evaluate.total_count(metrics, :update_request_count)
results[:average_update_requests] = Evaluate.average_count(metrics, :update_request_count)
results[:total_update_requests_per_type] = Evaluate.total_count_per_type(metrics, :update_request_count)
results[:average_update_requests_per_type] = Evaluate.total_count_per_type(metrics, :update_request_count)

results[:total_update_request_conflicts] = Evaluate.total_count(metrics, :update_request_conflict_count)
results[:average_update_request_conflicts] = Evaluate.average_count(metrics, :update_request_conflict_count)
results[:total_update_request_conflicts_per_type] = Evaluate.total_count_per_type(metrics, :update_request_conflict_count)
results[:average_update_request_conflicts_per_type] = Evaluate.total_count_per_type(metrics, :update_request_conflict_count)

results[:average_detection_time] = Evaluate.average_detection_time_elapsed(metrics)
results[:average_detection_time_per_type] = Evaluate.average_detection_time_elapsed_per_type(metrics)
results[:average_time_elapsed] = Evaluate.average_time_elapsed(metrics)
results[:average_time_elapsed_per_type] = Evaluate.average_time_elapsed_per_type(metrics)

File.open(File.expand_path("../#{test_dir}/evaluation_results.json",__FILE__), "w") do |f|
  f.puts JSON.pretty_generate(results)
end

puts "Correct?: #{results[:correctness]}"
puts "\n"

puts "#### messages sent ####"
puts "Total messages sent:\n #{results[:total_messages_sent]}"
puts "Average messages sent:\n #{results[:average_messages_sent]}"
puts "Total messages sent per type:\n #{results[:total_messages_sent_per_type]}"
puts "Average messages sent per type:\n #{results[:average_messages_sent_per_type]}"
puts "\n"

puts "#### messages received ####"
puts "Total messages received:\n #{results[:total_messages_received]}"
puts "Average messages received:\n #{results[:average_messages_received]}"
puts "Total messages received per type:\n #{results[:total_messages_received_per_type]}"
puts "Average messages received per type:\n #{results[:average_messages_received_per_type]}"
puts "\n"

puts "#### broadcasts ####"
puts "Total broadcasts:\n #{results[:total_broadcasts]}"
puts "Average broadcasts:\n #{results[:average_broadcasts]}"
puts "Total broadcasts per type:\n #{results[:total_broadcasts_per_type]}"
puts "Average broadcasts per type:\n #{results[:average_broadcasts_per_type]}"
puts "\n"

puts "#### update requests received ####"
puts "Total update requests received:\n #{results[:total_update_requests]}"
puts "Average update requests received:\n #{results[:average_update_requests]}"
puts "Total update requests received per type:\n #{results[:total_update_requests_per_type]}"
puts "Average update requests received per type:\n #{results[:average_update_requests_per_type]}"
puts "\n"

puts "#### update request conflicts received ####"
puts "Total update request conflicts received:\n #{results[:total_update_request_conflicts]}"
puts "Average update request conflicts received:\n #{results[:average_update_request_conflicts]}"
puts "Total update request conflicts received per type:\n #{results[:total_update_request_conflicts_per_type]}"
puts "Average update request conflicts received per type:\n #{results[:average_update_request_conflicts_per_type]}"
puts "\n"


puts "#### Time metrics ####"
puts "Average detection time:\n #{results[:average_detection_time]}"
puts "Average detection time per type:\n #{results[:average_detection_time_per_type]}"
puts "Average time elapsed:\n #{results[:average_time_elapsed]}"
puts "Average time elapsed per type:\n #{results[:average_time_elapsed_per_type]}"

