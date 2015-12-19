require 'rails_helper'

RSpec.describe School, type: :model do
  let(:school){ FactoryGirl.create :school }
  let(:student){ FactoryGirl.create :student, school: school }
  let(:bip){ FactoryGirl.create :bip, student: student }

  context 'validations' do
    it 'requires a school name' do
      expect(FactoryGirl.build(:school, name: "")).not_to be_valid
    end
    it 'requires a school address' do
      expect(FactoryGirl.build(:school, address: "")).not_to be_valid
    end
    it 'requires a school city' do
      expect(FactoryGirl.build(:school, city: "")).not_to be_valid
    end
    it 'requires a school state' do
      expect(FactoryGirl.build(:school, state: "")).not_to be_valid
    end
    it 'requires a school zip' do
      expect(FactoryGirl.build(:school, zip: "")).not_to be_valid
    end
  end
  context '#users' do
    it 'returns an array of coordinators, teachers, and speducators' do
      teacher = FactoryGirl.create(:teacher)
      school.teachers << teacher
      speducator = FactoryGirl.create(:speducator)
      school.speducators << speducator
      coordinator = FactoryGirl.create(:coordinator)
      school.coordinators << coordinator
      expect(school.users).to eq [coordinator, teacher, speducator]
    end
  end
  context '#active_goals' do
    it 'returns an array of goal objects' do
      3.times{ FactoryGirl.create(:goal, bip: bip) }
      expect(school.active_goals).to eq Goal.all
    end
  end
end
