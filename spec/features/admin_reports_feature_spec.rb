require 'rails_helper'

feature "Using the reports panel", js: false, focus: false do
  given(:school){ FactoryGirl.create :school, name: "test name" }
  given(:speducator){ FactoryGirl.create :speducator, school: school }
  given(:speducator2){ FactoryGirl.create :speducator, school: school, first_name: "TestName" }
  given(:student){ FactoryGirl.create :student, school: school, speducator: speducator, grade: 1, gender: "male", race: "African" }
  given(:student2){ FactoryGirl.create :student, school: school, speducator: speducator2, grade: 2, gender: "female", race: "White" }
  given(:teacher){ FactoryGirl.create :teacher, school: school  }
  given(:observation){ FactoryGirl.create :observation, student: student, user: teacher }
  given(:observation2){ FactoryGirl.create :observation, student: student2, user: teacher }
  given(:bip){ FactoryGirl.create :bip, student: student }
  given(:bip2){ FactoryGirl.create :bip, student: student2 }
  given(:goal){ FactoryGirl.create :goal, bip: bip, prompt: "Goal 1 Prompt", text: "Goal 1 Text", meme: "Time" }
  given(:goal2){ FactoryGirl.create :goal, bip: bip2, prompt: "Goal 1 Prompt", text: "Goal 1 Text", meme: "Time" }
  given!(:record){ FactoryGirl.create :record, observation: observation, goal: goal, result: 5}
  given!(:record2){ FactoryGirl.create :record, observation: observation, goal: goal2, result: 1}
  given!(:admin){ FactoryGirl.create :admin }
  given!(:coordinator){ FactoryGirl.create :coordinator, school: school }
  given!(:card){ FactoryGirl.create :card,  user: teacher, student: student }

  background do
    visit login_path
    within "#login_form" do
      fill_in 'email', with: admin.email
      fill_in 'password', with: admin.password
    end
    click_on 'Submit'
  end

  scenario 'by going to the reports dashboard' do
    click_on 'Reports'
    expect(page).to have_selector '#reportsPanel'
    expect(page).to have_selector '#schoolFilter'
    expect(page).to have_content "No school selected."
    expect(page).not_to have_selector ".graph"
    expect(page).not_to have_selector ".schoolData"
  end

  feature "Using a selected school" do
    background do
      click_on 'Reports'
      within '#schoolFilter' do
        select school.name, :from => 'school_id'
      end
      click_on 'Filter Results'
    end

    scenario 'by selecting a school to view' do
      expect(page).to have_selector '#reportsPanel'
      expect(page).to have_selector '#schoolFilter'
      expect(page).to have_selector '#sliceFilter'
      expect(page).to have_selector ".graph"
      expect(page).to have_selector ".schoolData"
      expect(page).not_to have_content "No school selected."
      expect(page).not_to have_content "- Grade Level: "

      table = find("#schoolTable")
      expect(table).to have_content "Total Staff"
      expect(table).to have_content "Total Students"
      expect(table).to have_content "Open Observations"
      expect(table).to have_content "Student Metrics"
      avg = find('#avg_student_performance')
      expect(avg).to have_content '60.0'
    end
    scenario 'by selecting a grade level to filter to' do
      within '#sliceFilter' do
        select "1", from: 'grade_lvl'
        click_on "Filter Results"
      end
      expect(page).to have_selector ".graph"
      expect(page).to have_selector ".schoolData"
      expect(page).not_to have_content "No school selected."
      expect(page).to have_content "Reports for: #{school.name} - Grade Level: #{student.grade}"

      table = find("#schoolTable")
      expect(table).to have_content "Total Staff"
      expect(table).to have_content "Total Students"
      expect(table).to have_content "Open Observations"
      expect(table).to have_content "Student Metrics"
      avg = find('#avg_student_performance')
      expect(avg).to have_content '100.0'
    end
    scenario 'by selecting a grade level to filter to and going back to any' do
      within '#sliceFilter' do
        select "1", from: 'grade_lvl'
        click_on "Filter Results"
      end
      expect(page).to have_content "Reports for: #{school.name} - Grade Level: #{student.grade}"

      avg = find('#avg_student_performance')
      expect(avg).to have_content '100.0'

      within '#sliceFilter' do
        select "any", from: 'grade_lvl'
        click_on "Filter Results"
      end
      expect(page).not_to have_content "Reports for: #{school.name} - Grade Level: #{student.grade}"
      expect(page).to have_content "Reports for: #{school.name}"
      expect(page).to have_selector ".graph"
      expect(page).to have_selector ".schoolData"
      expect(page).not_to have_content "No school selected."

      table = find("#schoolTable")
      expect(table).to have_content "Total Staff"
      expect(table).to have_content "Total Students"
      expect(table).to have_content "Open Observations"
      expect(table).to have_content "Student Metrics"
      avg = find('#avg_student_performance')
      expect(avg).to have_content '60.0'
    end
    scenario 'by selecting a gender to filter to and going back to any' do
      within '#sliceFilter' do
        select "Female", from: 'gender'
        click_on "Filter Results"
      end
      expect(page).to have_content "Reports for: #{school.name} - Gender: Female"

      avg = find('#avg_student_performance')
      expect(avg).to have_content '20.0'

      within '#sliceFilter' do
        select "any", from: 'gender'
        click_on "Filter Results"
      end
      expect(page).not_to have_content "Reports for: #{school.name} - Grade Level: Female"
      expect(page).to have_content "Reports for: #{school.name}"
      expect(page).to have_selector ".graph"
      expect(page).to have_selector ".schoolData"
      expect(page).not_to have_content "No school selected."

      table = find("#schoolTable")
      expect(table).to have_content "Total Staff"
      expect(table).to have_content "Total Students"
      expect(table).to have_content "Open Observations"
      expect(table).to have_content "Student Metrics"
      avg = find('#avg_student_performance')
      expect(avg).to have_content '60.0'
    end
    scenario 'by selecting a race to filter to and going back to any' do
      within '#sliceFilter' do
        select "White", from: 'race'
        click_on "Filter Results"
      end
      expect(page).to have_content "Reports for: #{school.name} - Race: White"

      avg = find('#avg_student_performance')

      expect(avg).to have_content '20.0'

      within '#sliceFilter' do
        select "any", from: 'race'
        click_on "Filter Results"
      end
      expect(page).not_to have_content "Reports for: #{school.name} - Race: White"
      expect(page).to have_content "Reports for: #{school.name}"
      expect(page).to have_selector ".graph"
      expect(page).to have_selector ".schoolData"
      expect(page).not_to have_content "No school selected."

      table = find("#schoolTable")
      expect(table).to have_content "Total Staff"
      expect(table).to have_content "Total Students"
      expect(table).to have_content "Open Observations"
      expect(table).to have_content "Student Metrics"
      avg = find('#avg_student_performance')
      expect(avg).to have_content '60.0'
    end
    scenario 'by selecting a special educator to filter to and going back to any' do
      within '#sliceFilter' do
        select speducator2.first_name, from: 'speducator_id'
        click_on "Filter Results"
      end
      expect(page).to have_content "Reports for: #{school.name} - Special Educator: #{speducator2.first_name}"

      avg = find('#avg_student_performance')

      expect(avg).to have_content '20.0'

      within '#sliceFilter' do
        select "any", from: 'speducator_id'
        click_on "Filter Results"
      end
      expect(page).not_to have_content "Reports for: #{school.name} - Special Educator: #{speducator2.first_name}"
      expect(page).to have_content "Reports for: #{school.name}"
      expect(page).to have_selector ".graph"
      expect(page).to have_selector ".schoolData"
      expect(page).not_to have_content "No school selected."

      table = find("#schoolTable")
      expect(table).to have_content "Total Staff"
      expect(table).to have_content "Total Students"
      expect(table).to have_content "Open Observations"
      expect(table).to have_content "Student Metrics"
      avg = find('#avg_student_performance')
      expect(avg).to have_content '60.0'
    end
    feature 'Selecting multiple filters' do
      given(:student3){ FactoryGirl.create :student, school: school, speducator: speducator2, grade: 1, gender: "male", race: "African" }
      given(:bip3){ FactoryGirl.create :bip, student: student3 }
      given(:goal3){ FactoryGirl.create :goal, bip: bip3, prompt: "Goal 1 Prompt", text: "Goal 1 Text", meme: "Time" }
      given!(:record3){ FactoryGirl.create :record, observation: observation, goal: goal3, result: 2}

      given(:student4){ FactoryGirl.create :student, school: school, speducator: speducator, grade: 2, gender: "male", race: "African" }
      given(:bip4){ FactoryGirl.create :bip, student: student4 }
      given(:goal4){ FactoryGirl.create :goal, bip: bip4, prompt: "Goal 1 Prompt", text: "Goal 1 Text", meme: "Time" }
      given!(:record4){ FactoryGirl.create :record, observation: observation, goal: goal4, result: 3}

      given(:student5){ FactoryGirl.create :student, school: school, speducator: speducator, grade: 2, gender: "female", race: "African" }
      given(:bip5){ FactoryGirl.create :bip, student: student5 }
      given(:goal5){ FactoryGirl.create :goal, bip: bip5, prompt: "Goal 1 Prompt", text: "Goal 1 Text", meme: "Time" }
      given!(:record5){ FactoryGirl.create :record, observation: observation, goal: goal5, result: 4}


      given(:student6){ FactoryGirl.create :student, school: school, speducator: speducator2, grade: 1, gender: "female", race: "African" }
      given(:bip6){ FactoryGirl.create :bip, student: student6 }
      given(:goal6){ FactoryGirl.create :goal, bip: bip6, prompt: "Goal 1 Prompt", text: "Goal 1 Text", meme: "Time" }
      given!(:record6){ FactoryGirl.create :record, observation: observation, goal: goal6, result: 5}

      scenario 'by selecting a multiple filters to filter to and going back to any' do
        within '#sliceFilter' do
          select "1", from: 'grade_lvl'
          click_on "Filter Results"
        end
        expect(page).to have_content "Reports for: #{school.name} - Grade Level: #{student.grade}"

        avg = find('#avg_student_performance')
        expect(avg).to have_content '80.0'

        within '#sliceFilter' do
          select speducator.first_name, from: 'speducator_id'
          click_on "Filter Results"
        end

        expect(page).to have_content "Reports for: #{school.name} - Grade Level: 1 - Special Educator: #{speducator.first_name}"
        avg = find('#avg_student_performance')
        expect(avg).to have_content '100.0'

        within '#sliceFilter' do
          select "2", from: 'grade_lvl'
          click_on "Filter Results"
        end

        expect(page).to have_content "Reports for: #{school.name} - Grade Level: 2 - Special Educator: #{speducator.first_name}"
        avg = find('#avg_student_performance')
        expect(avg).to have_content '70.0'

        within '#sliceFilter' do
          select "any", from: 'grade_lvl'
          select "any", from: 'speducator_id'
          select "Male", from: 'gender'
          click_on "Filter Results"
        end

        expect(page).to have_content "Reports for: #{school.name} - Gender: Male"
        avg = find('#avg_student_performance')
        expect(avg).to have_content '66.66666666666667'

        within '#sliceFilter' do
          select "White", from: 'race'

          click_on "Filter Results"
        end

        expect(page).to have_content "Reports for: #{school.name} - Gender: Male - Race: White"
        avg = find('#avg_student_performance')
        expect(avg).to have_content ''
      end
    end
  end
end