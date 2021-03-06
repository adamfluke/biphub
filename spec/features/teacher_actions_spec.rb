require 'rails_helper'

feature "Using teacher dashboard", js: false do
  given(:teacher){ FactoryGirl.create :teacher }
  given(:teacher_2){ FactoryGirl.create :teacher, school: teacher.school, first_name: 'TestTeacher' }
  given(:observation){ FactoryGirl.create :observation, user: teacher }
  given(:record){ FactoryGirl.create :record, observation: observation }

  background do
    visit login_path
    within "#login_form" do
      fill_in 'email', with: teacher.email
      fill_in 'password', with: teacher.password
    end
    click_on 'Submit'
  end

  scenario 'going to the teacher dashboard' do
    visit root_path
    click_on 'Dashboard'

    expect(page).to have_selector '#teacherPanel'
  end

  feature "Teacher panel contents" do
    context "There are no records" do
      scenario 'there is a confirmation message that the card queue is empty' do
        expect(page).to have_content "Your queue is empty. Good job!!"
      end
    end

    context "There are unanswered observations" do
      background do
        3.times do
          record
        end
        click_on 'Dashboard'
      end
      scenario 'by seeing if the empty queue message is not there' do
        expect(page).not_to have_content "Your queue is empty. Good job!!"
      end
      scenario 'by seeing if there is an unanswered observation' do
        expect(page).to have_selector "#liveObservation"
        expect(page).to have_content observation.student.first_name
      end
    end
  end

  feature "Can Use the ObservationsPanel" do
    scenario 'by seeing a message if there are no observations'  do
      expect(page).to have_selector "#observationsTable"
      expect(page).to have_content "We didn't find any answered observations"
    end
    scenario 'by seeing the observations they have answered'  do
      observation
      click_on 'Dashboard'
      expect(page).to have_content teacher.last_name
    end
    scenario 'but not seeing the observations they have not answered'  do
      record
      click_on 'Dashboard'
      expect(page).not_to have_selector ".observationRow"
      expect(page).to have_content "We didn't find any answered observations"
    end
    scenario 'by seeing a message if there are no records'  do
      observation
      click_on 'Dashboard'
      expect(page).to have_content "There were no records associated with this observation."
    end
    scenario 'by seeing the record results for the observations'  do
      record.update_attribute(:result, 10)
      click_on 'Dashboard'
      expect(page).to have_content "10"
    end
    scenario 'by editing/updating an observation with no records' do
      observation
      teacher_2
      click_on 'Dashboard'
      click_on 'edit'
      within '.edit_observation' do
        select 'TestTeacher', :from => 'observation_user_id'
      end
      click_on 'Submit'

      expect(page).to have_selector '#observationInformation'
      expect(page).to have_content 'TestTeacher'
      expect(find('#observationRecords')).to have_content "There are no records associated with this observation"
    end
    scenario 'by editing/updating the record results for a observation'  do
      record.update_attribute(:result, 10)
      teacher_2
      click_on 'Dashboard'
      click_on 'edit'
      expect(page).to have_selector '.edit_observation'
      within '.edit_observation' do
        select 'TestTeacher', :from => 'observation_user_id'
        fill_in 'observation_records_attributes_0_result', with: 1
      end
      click_on 'Submit'

      expect(page).to have_selector '#observationInformation'
      expect(page).to have_content 'TestTeacher'
      expect(find('#observationRecords')).to have_content 1
    end
    feature "Filtering the results of the table" do
      given(:observation1){ FactoryGirl.create :observation, user: teacher, student: FactoryGirl.create(:student, first_name: 'test') }

      scenario 'by not seeing the filter form if there are no observations'  do
        expect(page).to have_selector "#observationsTable"
        expect(page).not_to have_selector "#filterBar"
      end
      scenario 'by using the filter form to select only one student'  do
        observation
        observation1
        click_on 'Dashboard'
        expect(page).to have_selector "#observationsTable"
        expect(page).to have_selector "#filterBar"

        within '#studentFilter' do
          select observation1.student.first_name, :from => 'student_id'
        end
        click_on 'Filter Results'

        expect(page).to have_content observation1.student.first_name
        expect(find("#observationsTable table")).not_to have_content observation.student.first_name
      end
    end
  end
end

