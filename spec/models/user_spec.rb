require 'rails_helper'

RSpec.describe User, type: :model do

  
  let(:developer) { FactoryGirl::create(:developer) }
  let(:device) { FactoryGirl::create(:device) }
  let(:user) do
    us = FactoryGirl::create(:user)
    us.devices << device
    us
  end
  let(:second_user) do
    us = FactoryGirl::create(:user)
    us.devices << FactoryGirl::create(:device)
    us
  end
  let(:approval) { create_approval(user, second_user) }

  describe "relationships" do
    it "should have some devices" do
      expect(user.devices.last).to eq device 
    end
  end

  describe "methods" do
    it "should create an authentication token on save" do
      user = FactoryGirl::build :user

      expect(user.authentication_token).to be nil
      user.save
      expect(user.authentication_token).to be_an_instance_of String
    end
  end

  describe "approvals" do

    it "should approve a developer" do
      expect(user.pending_approvals.count).to be 0
      expect(user.approved_developer? developer).to be false
      
      user.approvals << Approval.create(approvable: developer, approvable_type: 'Developer', status: 'developer-requested')
      user.save

      expect(user.pending_approvals.count).to be 1
      expect(user.developers.count).to be 0

      Approval.accept(user,developer,'Developer')
      expect(user.pending_approvals.count).to be 0
      expect(user.developers.count).to be 1
    end

    it "should approve devices for a developer by default when a developer is approved" do
      user.approvals <<  Approval.create(approvable: developer, approvable_type: 'Developer', status: 'developer-requested')
      Approval.accept(user,developer,'Developer')
      expect(user.devices.first.developers.count).to be 1
      expect(user.devices.first.developers.first).to eq developer
      expect(user.devices.first.privilege_for(developer)).to eq "complete"
    end

  end

  describe "privileges" do
    context 'between a developer and a user' do
      before do
        Approval.link(user,developer,'Developer')
        Approval.accept(user,developer,'Developer')
      end

      it "should have device privileges by default" do
        expect( user.devices.first.privilege_for developer ).to eq "complete"
      end

      it "should be able to set privilege" do
        user.devices.first.change_privilege_for developer, "disallowed"
        expect( user.devices.first.privilege_for developer ).to eq "disallowed"
      end
    end
  end

  describe "notifications" do
    it "should have a notification if there's a pending approval" do
      Approval.link(user,developer,'Developer')

      expect(user.notifications).to be_an_instance_of Array
      expect(user.notifications.length).to eq 1
      expect(user.notifications.first[:notification][:msg]).to_not be nil
    end
  end

end
