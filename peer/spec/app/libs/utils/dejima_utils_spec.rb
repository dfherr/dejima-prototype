require 'rails_helper'

RSpec.describe DejimaManager do
  describe "check_local_peer_groups" do
    it "Test" do
      DejimaManager.check_local_peer_groups([GovernmentUser])
      require "pry"
      binding.pry
      DejimaManager.detect_peer_groups
    end
  end
end
