require 'rails_helper'

RSpec.describe Api::V1::Users::PermissionsController, type: :controller do
  include ControllerMacros
  let(:device) { FactoryGirl::create :device }
  let(:user) do
    u = FactoryGirl::create :user
    u.devices << device
    u
  end
  let(:second_user) { FactoryGirl::create :user }
  let(:developer) { FactoryGirl::create :developer }
  let(:permission) do
    device.developers << developer
    Permission.last
  end

  before do
    request.headers["X-User-Token"] = user.authentication_token
    request.headers["X-User-Email"] = user.email
  end

  describe 'update' do
    it 'should update the privilege level, bypass_fogging and show_history attributes' do
       put :update, {
        id: permission.id,
        device_id: device.id,
        user_id: user.id,
        permission: {
          privilege: 'last_only',
        },
      }
      expect(res_hash[:privilege]).to eq 'last_only'
    end

    it 'should fail to update permission if user does not own permission' do
      request.headers["X-User-Token"] = second_user.authentication_token
      request.headers["X-User-Email"] = second_user.email
      put :update, {
        user_id: second_user.id,
        device_id: device.id,
        id: permission.id,
        permission: {
          bypass_fogging: true,
        },
      }
      expect(response.status).to be 403
      expect(res_hash[:message]).to eq 'You do not control that permission'
    end
  end

end