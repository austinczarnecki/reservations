class Category < ActiveRecord::Base
  include Searchable
  searchable_on(:name)

  has_many :equipment_models, :dependent => :destroy

  validates :name,                :presence => true,
                                  :uniqueness => true

  validates :sort_order,          :uniqueness => true,
                                  :numericality => {
                                    :allow_nil => false,
                                    :integer_only => true,
                                    :greater_than_or_equal_to => 0 }

  validates :max_per_user,
            :max_checkout_length,
            :max_renewal_length,
            :max_renewal_times,
            :renewal_days_before_due,
                                  :numericality => {
                                    :allow_nil => true,
                                    :integer_only => true,
                                    :greater_than_or_equal_to => 0 }

  attr_accessible :name, :max_per_user,
                  :max_checkout_length, :deleted_at,
                  :max_renewal_times, :max_renewal_length,
                  :renewal_days_before_due

  nilify_blanks :only => [:deleted_at]

  # table_name is needed to resolve ambiguity for certain queries with 'includes'
  scope :active, where("#{table_name}.deleted_at is null")


  def maximum_per_user
    max_per_user || "unrestricted"
  end

  def maximum_renewal_length
    max_renewal_length || 0
  end

  def maximum_renewal_times
    max_renewal_times || "unrestricted"
  end

  def maximum_renewal_days_before_due
    renewal_days_before_due || "unrestricted"
  end

  def maximum_checkout_length
    max_checkout_length || "unrestricted"
    #self.max_checkout_length ? ("#{max_checkout_length} days") : "unrestricted"
  end

  #TODO: this appears to be dead code - verify and remove
  def self.select_options
    self.find(:all, :order => 'name ASC').collect{|item| [item.name, item.id]}
  end

  #TODO: this appears to be dead code - verify and remove
  def self.singular_select_options
    (self.find(:all, :order => 'name ASC') - [self.find_by_name("Accessories")]).collect{|item| "<option value='#{item.id}'>#{item.name.singularize}</option>"}.join.html_safe
  end
end
