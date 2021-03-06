require "rails_helper"

RSpec.describe AdminsController, :type => :controller do
  describe "GET #show" do
    let(:admin){ FactoryGirl.create(:admin) }
    before(:each){
      allow(controller).to receive(:authorize_admin)
      allow(controller).to receive(:authorize)
    }
    subject { get :show, id: admin.id }

    it 'receives authorize_admin before_filter' do
      expect(controller).to receive :authorize_admin
      subject
    end
    it 'recives authorize before_filter' do
      expect(controller).to receive :authorize
      subject
    end
    it { is_expected.to be_success }
    it { is_expected.to have_http_status 200 }
    it { is_expected.to render_template "show" }
  end
end