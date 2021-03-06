require 'rails_helper'

RSpec.describe Student, type: :model, focus: false do
  let(:student){ FactoryGirl.create :student, first_name: 'Joseph', last_name: 'Hammond' }

  context 'validations' do
    it 'requires a first_name' do
      expect(FactoryGirl.build(:student, first_name: "")).not_to be_valid
    end
    it 'requires an end time' do
      expect(FactoryGirl.build(:student, last_name: "")).not_to be_valid
    end
    it 'requires a school' do
      expect(FactoryGirl.build(:student, school: nil)).not_to be_valid
    end
  end

  describe "Student Class Methods" do
    let(:teacher){ FactoryGirl.create :teacher }
    let(:bip){ FactoryGirl.create :bip }
    before(:each){
      student.bips << bip
      3.times do
        goal = FactoryGirl.create(:goal)
        bip.goals << goal
      end
      3.times{ student.cards << FactoryGirl.create(:card, user: teacher, student: student) }
      student.cards.each do |card|
        observation = FactoryGirl.create(:observation, student: student, user: teacher)
      end
      student.bips.first.goals.each do |goal|
        student.observations.each do |observation|
          goal.records << FactoryGirl.create(:record, observation: observation, result: rand(1..10))
        end
      end
    }

    context '.create_daily_records' do
      it 'returns creates record instances for each goal and observation' do
        expect(Student.create_daily_records).to eq true
        expect{Student.create_daily_records}.to change{Record.all.count}.by(9)
      end
      it "doesn't break if there are students with no bips" do
        FactoryGirl.create(:student)

        expect(Student.create_daily_records).to eq true
        expect{Student.create_daily_records}.to change{Record.all.count}.by(9)
      end
    end
    context '.create_daily_observations' do
      it 'returns a collection of observations' do
        expect(Student.create_daily_observations).to be_a Hash
      end
      it 'creates record instances' do
        expect{Student.create_daily_observations}.to change{Observation.all.count}.by(3)
      end
    end
    context '.get_records_for_goals' do
      it 'returns a collection of records' do
        expect(student.get_records_for_goals).to be_a Array
      end
      context 'when there is a single bip with three goals, each with a record' do
        it 'an array of hashes representing goals and associated records is returned' do
          expect(student.get_records_for_goals[0]).to be_a Hash
        end
        it "each Hash has a Goal Active Record Object as the value of 'goal'" do
          expect(student.get_records_for_goals[0]["goal"]).to be_a Goal
        end
        it "an array of records is returned as the value of 'records'" do
          expect(student.get_records_for_goals[0]["records"][0]).to be_a Record
        end
      end
    end
  end
end
