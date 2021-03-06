class Processid < ActiveRecord::Base
  include UserSession

  before_save :calculate_field_var_table_name
  before_save :calculate_field_routine_name
  has_and_belongs_to_many :variables

  attr_accessor :variable_list

  scope :draft,       -> { where(status: Constants::STATUS[:SALA1]) }
  scope :development, -> { where(status: Constants::STATUS[:SALA2]) }
  scope :done,        -> { where(status: Constants::STATUS[:PRODUCAO]) }

  scope :recent, -> { order(updated_at: :desc) }

  validates :process_number, uniqueness: true, allow_blank: true, if: :current_user_is_room2?
  validates :process_number, presence: true, if: :current_user_is_room2?
  validates :mnemonic, presence: true, if: :current_user_is_room2?
  validates :mnemonic, uniqueness: true, allow_blank: true, if: :current_user_is_room2?
  validates :routine_name, presence: true, if: :current_user_is_room2?
  validates :var_table_name, presence: true, if: :current_user_is_room2?
  validates :conference_rule, presence: true, length: { maximum: 100 }, if: :current_user_is_room2?
  validates :acceptance_percent, presence: true, if: :current_user_is_room2?
  validates_inclusion_of :keep_previous_work, in: [true, false], if: :current_user_is_room2?
  validates :counting_rule, presence: true, length: { maximum: 100 }, if: :current_user_is_room2?
  validates :notes, presence: true, length: { maximum: 500 }, if: :current_user_is_room2?

  def code
    "PR#{self.id.to_s.rjust(3,'0')}"
  end

  def set_variables(variable_list = nil)
    self.variables = []

    variable_list.to_a.each { |var| self.variables << Variable.find(var.first) }
  end

  def status_screen_name
    mnemonic[0..19] if mnemonic?
  end

  private

  def calculate_field_var_table_name
    self.var_table_name = self.mnemonic? ? "VAR_#{mnemonic}".upcase : nil
  end

  def calculate_field_routine_name
    self.routine_name = self.process_number? ? "CD5PV#{process_number}" : nil
  end
end
