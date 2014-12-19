class Processid < ActiveRecord::Base
  before_save :calculate_field_var_table_name
  before_save :calculate_field_routine_name
  has_and_belongs_to_many :variables

  attr_accessor :variable_list

  scope :draft,       -> { where(status: Constants::STATUS[:SALA1]) }
  scope :development, -> { where(status: Constants::STATUS[:SALA2]) }
  scope :done,        -> { where(status: Constants::STATUS[:PRODUCAO]) }

  def code
    "PR#{self.id.to_s.rjust(3,'0')}"
  end

  def set_variables(variable_list = nil)
    if variable_list
      self.variables = []
      variable_list.each { |var| self.variables << Variable.find(var.first) }
    else
      self.variables = []
    end
  end

  def status_screen_name
    unless mnemonic.nil?
      res = mnemonic[0..20]
    end
  end

  def calculate_field_var_table_name
    if self.mnemonic?
      self.var_table_name = "VAR_#{mnemonic}".upcase
    else
      self.var_table_name = nil
    end
  end

  def calculate_field_routine_name
    if self.process_number?
      self.routine_name = "CD5PV#{process_number}"
    else
      self.routine_name = nil
    end
  end

end
