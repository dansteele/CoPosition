require 'rails_helper'

RSpec.describe RedboxCheckin, type: :model do


  describe "realtionships" do

    it "should have a device" do
      checkin = FactoryGirl::create(:redbox_checkin)
      checkin.device = Device.create(imei: 1234)
      expect(checkin.device.imei).to eq "1234"
    end

  end
  
  describe "parsing" do
    it "should take a string without a GPS and return an object" do
      @checkin = RedboxCheckin.create_from_string(RequestFixture.new.no_gps)
      expect(@checkin.to_json).to eq RedboxCheckin.last.to_json
      expect(@checkin.imei).to eq "356938035643809"
      expect(@checkin.time).to eq "064951.000"
      expect(@checkin.date).to eq "260406"
      expect(@checkin.rotorspeed).to be 490.01
      expect(@checkin.device).to be nil
    end

    it "should add_device if asked to do so" do
      @checkin = RedboxCheckin.create_from_string(RequestFixture.new.no_gps, add_device: true)
      expect(@checkin.to_json).to eq RedboxCheckin.last.to_json
      expect(@checkin.imei).to eq "356938035643809"
      expect(@checkin.time).to eq "064951.000"
      expect(@checkin.date).to eq "260406"
      expect(@checkin.rotorspeed).to be 490.01
      expect(@checkin.device).to_not be nil
    end



    it "should take a string with a GPS and return an object" do
      @checkin = RedboxCheckin.create_from_string(RequestFixture.new.w_gps)
      expect(@checkin.to_json).to eq RedboxCheckin.last.to_json
      expect(@checkin.status).to eq "A"
      expect(@checkin.imei).to eq "356938035643809"
    end


    it "should return a new object without creating it, when asked" do
      @checkin = RedboxCheckin.new_from_string(RequestFixture.new.w_gps)
      expect(@checkin.id).to be nil
      expect(@checkin.status).to eq "A"
      expect(@checkin.imei).to eq "356938035643809"
    end
  end

  describe "methods" do
    it "should give you a range array" do
      expect(RedboxCheckin.range_array(1,3)).to eq [1,2,3]
    end
  end

end