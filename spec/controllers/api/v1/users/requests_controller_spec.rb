require 'rails_helper'

RSpec.describe Api::V1::Users::RequestsController, type: :controller do
  include ControllerMacros

  let(:developer) { create_developer }
  let(:user) do
    us = FactoryGirl::create :user
    Approval.link(us,developer,'Developer')
    Approval.accept(us,developer,'Developer')
    us
  end

  before do
    request.headers['X-Api-Key'] = developer.api_key
  end


  it 'should get a list of requests' do
    21.times { get :index, user_id: user.id }
    expect(res_hash.length).to eq 21
  end

  it 'should get a list of (developer) requests specific to a developer' do
    get :index, {
      user_id: user.id,
      developer_id: developer.id
    }
    expect(res_hash.first['developer_id']).to eq(developer.id)
    get :index, {
      user_id: user.id,
      developer_id: 99999
    }
    expect(response.body).to eq("[]")
  end

  it 'should get the second to last request related to this user' do
    21.times { get :index, user_id: user.id }
    get :last, user_id: user.id
    expect(res_hash.first['action']).to eq "index"
    expect(res_hash.length).to eq 1
  end
end
