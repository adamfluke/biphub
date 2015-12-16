class Student < ActiveRecord::Base
  belongs_to :school
  belongs_to :speducator
  has_many :teams
  has_many :staff_members, through: :teams, source: :user
  has_many :cards
  has_many :teachers, through: :cards, source: :user
  has_many :bips
  has_many :observations
  has_many :records, through: :observations

  validates :school, :first_name, :last_name, presence: true

  def self.create_daily_records
    observations = self.create_daily_observations
    self.all.each do |student|
      unless student.bips.empty?
        goals = student.bips.last.goals
        observations[student.id].each do |observation|
        Record.create_record_group observation, goals
        end
      end
    end
    true
  end
  def self.create_daily_observations
    observations = {}
    self.all.each do |student|
      observation = Observation.create_from_cards student.cards
      observations[student.id] = observation
    end
    observations
  end

  def nickname
    self.create_nickname unless self.alias
    self.alias
  end
  def create_nickname
    nickname = self.first_name.slice(0..1).upcase
    nickname += self.last_name.slice(0..1).upcase
    self.update_attribute :alias, nickname
  end

  def get_records_for_goals
    student_records = []
    self.bips.each do |bip|
      bip.goals.each do |goal|
        goal.records.each do |record|
          student_records << record
          return student_records
        end
      end
    end
  end
end
