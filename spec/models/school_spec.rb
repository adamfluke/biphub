require 'rails_helper'

RSpec.describe School, type: :model, focus: false do

  it_behaves_like "sliceable"

  let(:school){ FactoryGirl.create :school }
  let(:student){ FactoryGirl.create :student, school: school, grade: 1, race: "African" }
  let(:student2){ FactoryGirl.create :student, school: school, grade: 2, race: "White" }
  let(:bip){ FactoryGirl.create :bip, student: student }
  let(:bip2){ FactoryGirl.create :bip, student: student2 }
  let(:goal){ FactoryGirl.create :goal, bip: bip, meme: "Qualitative" }
  let(:goal2){ FactoryGirl.create :goal, bip: bip2, meme: "Qualitative" }
  let(:observation){ FactoryGirl.create :observation, student: student }
  let(:observation2){ FactoryGirl.create :observation, student: student2 }
  let(:teacher){ FactoryGirl.create(:teacher, school: school) }
  let(:speducator){ FactoryGirl.create(:speducator, school: school) }
  let(:coordinator){ FactoryGirl.create(:coordinator, school: school) }

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
  context '#student_count' do
    it 'returns zero if there are no students assigned' do
      allow(school).to receive(:students).and_return([])
      expect(school.student_count).to eq 0
    end
    it 'returns one if there is a student in the school' do
      allow(school).to receive(:students).and_return([student])
      expect(school.student_count).to eq 1
    end

    it 'it accepts an optional grade level' do
      student
      student2
      expect(school.student_count(grade: 2)).to eq 1
    end
  end

  describe 'tests with stubbed .students' do
    before(:each){
      allow(school).to receive(:students).and_return([student, student2])
    }

    context '#users' do
      it 'returns an array of coordinators, teachers, and speducators' do
        allow(school).to receive(:teachers).and_return([teacher])
        allow(school).to receive(:speducators).and_return([speducator])
        allow(school).to receive(:coordinators).and_return([coordinator])

        expect(school.users).to eq [coordinator, teacher, speducator]
      end
    end

    context '#grade_levels' do
      it 'returns [] if there are no students with grades' do
        student.update_attribute(:grade, nil)
        student2.update_attribute(:grade, nil)
        expect(school.grade_levels).to eq []
      end
      it 'returns an array of grades for a school' do
        expect(school.grade_levels).to eq [1,2]
      end
      it 'returns a unique array of grades' do
        student2.update_attribute(:grade, 1)
        expect(school.grade_levels).to eq [1]
      end
      it 'the return is sorted' do
        student.update_attribute(:grade, 2)
        student2.update_attribute(:grade, 1)
        expect(school.grade_levels).to eq [1, 2]
      end
      it 'The return ignores nil before sorting' do
        student.update_attribute(:grade, nil)
        student2.update_attribute(:grade, 1)
        expect(school.grade_levels).to eq [1]
      end
    end
    context '#races' do
      it 'returns nil if there are no students with races' do
        student.update_attribute(:race, nil)
        student2.update_attribute(:race, nil)
        expect(school.races).to eq []
      end
      it 'returns an array of races for a school' do
        expect(school.races).to eq ["African", "White"]
      end
      it 'returns a unique array of races' do
        student.update_attribute(:race, "White")
        expect(school.races).to eq ["White"]
      end
    end
  end
  context '#active_goals' do
    it 'returns an array of goal objects' do
      allow_any_instance_of(Student).to receive(:active_goals).and_return([goal, goal2])
      expect(school.active_goals.size).to eq 4
      expect(school.active_goals[0]).to eq goal
    end
  end
  context '#active_goals_count' do
    it 'returns an integer count of goals' do
      3.times{ FactoryGirl.create(:goal, bip: bip) }
      expect(school.active_goals_count).to eq 3
    end
    it 'accepts filters and returns the correct count' do
      3.times{ FactoryGirl.create(:goal, bip: bip) }
      3.times{ FactoryGirl.create(:goal, bip: bip2) }

      expect(school.active_goals_count(grade: 1)).to eq 3
    end
  end
  context '#observations_count' do
    it 'returns an integer count of observations' do
      3.times{ FactoryGirl.create(:observation, student: student) }
      expect(school.observations_count).to eq 3
    end
    it 'accepts filters and returns the correct count' do
      3.times{ FactoryGirl.create(:observation, student: student) }
      3.times{ FactoryGirl.create(:observation, student: student2) }

      expect(school.observations_count(grade: 1)).to eq 3
    end
  end
  context '#records_count' do
    it 'returns an integer count of records' do
      3.times{ FactoryGirl.create(:record, observation: observation) }
      expect(school.records_count).to eq 3
    end
    it 'accepts filters and returns the correct count' do
      3.times{ FactoryGirl.create(:record, observation: observation) }
      3.times{ FactoryGirl.create(:record, observation: observation2) }

      expect(school.records_count(grade: 1)).to eq 3
    end
  end
  context '#unanswered_observations' do
    before(:each){
      3.times{
        observation = FactoryGirl.create(:observation, student: student, start: Time.now, finish: Time.now)
        FactoryGirl.create(:record, observation: observation)
      }
    }
    it 'returns an array of unanswered observations objects' do
      expect(school.unanswered_observations).to eq Observation.all
    end
    it 'returns only the ones greater than 1 day past finish day' do
      day_old = FactoryGirl.create(:observation, student: student, start: Time.now - 1.day, finish: Time.now - 1.day)
      FactoryGirl.create(:record, observation: day_old)

      expect(school.unanswered_observations(trailing: 1).length).to eq 1
      expect(school.unanswered_observations(trailing: 1)[0]).to eq day_old
    end
    it 'returns only the ones greater than 7 days past finish day' do
      seven_day_old = FactoryGirl.create(:observation, student: student, start: Time.now - 7.day, finish: Time.now - 7.day)
      FactoryGirl.create(:record, observation: seven_day_old)

      expect(school.unanswered_observations(trailing: 7).length).to eq 1
      expect(school.unanswered_observations(trailing: 7)[0]).to eq seven_day_old
    end
    it 'selects only the observations that match the filter passed in' do
      FactoryGirl.create(:record, observation: observation2)

      expect(school.unanswered_observations(filter: {grade: 2}).length).to eq 1
    end
    it 'handles nil values in filter' do
      FactoryGirl.create(:record, observation: observation2)

      expect(school.unanswered_observations(filter: {grade: nil, race: nil}).length).to eq 4
    end
    context "#teachers_with_unanswered_observations" do
      it "returns a collection of teachers" do
        expect(school.teachers_with_unanswered_observations.length).to eq 3
      end
      it "returns a unique collection of teachers" do
        Observation.all.each do |observation|
          observation.user = teacher
          observation.save
        end

        expect(school.teachers_with_unanswered_observations.length).to eq 1
        expect(school.teachers_with_unanswered_observations[0]).to eq teacher
      end
    end
  end
  context '#observation_date_range' do
    let!(:record1){ FactoryGirl.create :record, goal: goal, observation: observation, result: 5 }
    let(:student2){ FactoryGirl.create :student, school: school, grade: 2 }
    let(:observation2){ FactoryGirl.create :observation, student: student2 }
    let(:record2){ FactoryGirl.create :record, goal: goal, observation: observation2, result: 5 }

    it 'returns an array with the date of the observations' do
      expect(school.observation_date_range).to eq [observation.finish.to_date]
    end
    it 'the array has only unique dates' do
      record2
      expect(school.observation_date_range).to eq [observation.finish.to_date]
    end
    it 'it filters out dates where student-performance is nil' do
      observation2.update_attribute(:finish, Date.today - 1.day)
      record2.update_attribute(:result, nil)
      expect(school.observation_date_range).to eq [observation.finish.to_date]
    end
    it 'sorts the dates oldest to newest' do
      observation2.update_attribute(:finish, Date.today - 1.day)
      record2
      expect(school.observation_date_range).to eq [observation2.finish.to_date, observation.finish.to_date]
    end
    context 'it takes optional filter arguement' do
      it 'selects only the dates where observations match the filter passed in' do
        observation2.update_attribute(:finish, Date.today - 1.day)
        FactoryGirl.create(:record, observation: observation2, result: 1)

        expect(school.observation_date_range(grade: 2).length).to eq 1
      end
    end
  end
end