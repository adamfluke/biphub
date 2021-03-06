class School < ActiveRecord::Base
  include Sliceable

  has_many :coordinators, dependent: :destroy
  has_many :teachers, dependent: :destroy
  has_many :speducators, dependent: :destroy
  has_many :students, dependent: :destroy
  has_many :observations, through: :students
  has_many :records, through: :students

  validates :name, :address, :city, :state, :zip, presence: true

  def users
  	self.coordinators + self.teachers + self.speducators
  end
  def active_goals
    self.students.map{ |student| student.active_goals }.flatten
  end
  def active_goals_count filters = {}
    if filters.length > 0
      self.students.where(filters).map{ |student| student.active_goals }.flatten.count
    else
      self.students.map{ |student| student.active_goals }.flatten.count
    end
  end
  def observations_count filters = {}
    if filters.length > 0
      self.students.where(filters).map{ |student| student.observations }.flatten.count
    else
      self.students.map{ |student| student.observations }.flatten.count
    end
  end
  def records_count filters = {}
    if filters.length > 0
      self.students.where(filters).map{ |student| student.records }.flatten.count
    else
      self.students.map{ |student| student.records }.flatten.count
    end
  end
  def grade_levels
    self.students.map{ |student| student.grade }.uniq.compact.sort
  end
  def student_count options = {}
    selectors = make_selectors(options)

    if selectors.length > 0
      students = self.students.where(selectors)
    else
      students = self.students
    end

    students.count
  end
  def races
    self.students.map{ |student| student.race }.uniq.compact.sort
  end
  def unanswered_observations options = {}
    trailing = options.fetch(:trailing, 0)
    selectors = options.fetch(:filter, nil)

    if selectors
      students = self.students.where(selectors.compact)
    end

    unanswered = self.observations.select{|observation| !observation.is_answered? }
    unanswered = unanswered.select{|observation| students.any?{|student| student ==observation.student } } if selectors

    limit = DateTime.now - trailing
    unanswered.select{|observation| observation.finish < limit }
  end
  def teachers_with_unanswered_observations
    self.unanswered_observations.map{ |observation| observation.user }.uniq
  end
  def observation_date_range options = {}
    selectors = make_selectors options

    if selectors.compact.length > 0
      students = self.students.where(selectors.compact)
      observations = students.map{|student| student.observations }.flatten
    else
      observations = self.observations
    end

    answered_observations = observations.select{ |observation| observation.is_answered? }
    answered_observations.map{|observation| observation.finish.to_date }.uniq.sort
  end
  def avg_student_performance options = {}
    trailing = options.fetch(:trailing, nil)
    date = options.fetch(:date, nil)
    selectors = make_selectors(options)

    if selectors.length > 0
      students = self.students.where(selectors)
    else
      students = self.students
    end

    results = students.map{|student| student.avg_performance(trailing: trailing, date: date) }.compact

    if results.length > 0
      average_result = results.inject(0.0) { |sum, el| sum + el } / results.size
    else
      nil
    end
  end
  def avg_student_growth options = {}
    selectors =  make_selectors options
    students = self.students.where(selectors.compact)
    results = students.map{|student| student.avg_growth }.compact
    if results.length > 0
      average_result = results.inject(0.0) { |sum, el| sum + el } / results.size
    else
      nil
    end
  end
end
