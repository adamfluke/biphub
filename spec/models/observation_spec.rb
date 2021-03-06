require 'rails_helper'

RSpec.describe Observation, type: :model do
  context 'validations' do
    it 'requires a User' do
      expect(FactoryGirl.build(:observation, user: nil)).not_to be_valid
    end
    it 'requires a Student' do
      expect(FactoryGirl.build(:observation, student: nil)).not_to be_valid
    end
    it 'requires a start time' do
      expect(FactoryGirl.build(:observation, start: nil)).not_to be_valid
    end
    it 'requires an end time' do
      expect(FactoryGirl.build(:observation, finish: nil)).not_to be_valid
    end
  end

  context '.create_from_cards' do
    let(:student){ FactoryGirl.create :student }
    let(:teacher){ FactoryGirl.create :teacher }
    let(:cards){
      3.times do
        FactoryGirl.create :card, student_id: student.id, user_id: teacher.id
      end
      student.cards
    }

    it 'raises an error if not passed a group of cardss' do
      expect{Observation.create_from_cards(["card"])}.to raise_error ArgumentError, 'Cards arguement contains objects that are not cards'
    end
    it 'creates Observation instances' do
      expect{Observation.create_from_cards(cards)}.to change{Observation.all.count}.by(3)
    end
    it 'returns a collections of observations' do
      expect(Observation.create_from_cards(cards)).to be_an Array
      expect(Observation.create_from_cards(cards)[0]).to be_a Observation
    end
  end

  context '.unanswered_observation_collection' do
    let(:teacher){ FactoryGirl.create :teacher }
    let(:observations){
      3.times do
        observation = FactoryGirl.create :observation, user_id: teacher.id
        FactoryGirl.create :record, observation: observation
      end
      3.times do
        observation = FactoryGirl.create :observation, user_id: teacher.id
        FactoryGirl.create :record, observation: observation, result: 'answered'
      end
      teacher.observations
    }

    it 'raises an error if not passed a group of observations' do
      expect{Observation.unanswered_observation_collection(["observation"])}.to raise_error ArgumentError, 'Observations arguement contains objects that are not observations'
    end
    it 'returns a collections of observations' do
      collection = Observation.unanswered_observation_collection(observations)
      expect(collection[0]).to be_an Array
      expect(collection[0][0]).to be_a Observation
      expect(collection[0][1]).to be_a Array
      expect(collection[0][1][0][:id]).to be_truthy
      expect(collection[0][1][0][:meme]).to eq observations[0].records[0].goal.meme
      expect(collection[0][1][0][:prompt]).to eq observations[0].records[0].goal.prompt
      expect(collection[0][2]).to be_a Hash
      expect(collection[0][2][:nickname]).to eq observations[0].student.nickname

      expect(collection.size).to eq 3
    end
  end

  context "#is_answered?" do
    let(:observation) { Observation.create }
    let(:record) { FactoryGirl.create :record }

    it 'returns true if there are no records' do
      expect(observation.is_answered?).to be true
    end

    it 'returns false if there is unanswered records' do
      observation.records << record
      expect(observation.is_answered?).to be false
    end

  end
  context "#records_with_prompt" do
    let(:goal){ FactoryGirl.create :goal, prompt: "How many?" }
    let(:observation) { Observation.create }
    let(:record) { FactoryGirl.create :record, observation: observation, goal: goal }

    it 'returns a collection of records with prompts added' do
      expect(observation.records_with_prompt).to be_truthy
    end
  end
end
