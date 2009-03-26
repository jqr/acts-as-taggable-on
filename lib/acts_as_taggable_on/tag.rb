class Tag < ActiveRecord::Base
  has_many :taggings
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  # LIKE is used for cross-database case-insensitivity
  def self.find_or_create_with_like_by_name(name)
    find(:first, :conditions => ["name LIKE ?", name]) || create(:name => name)
  end
  
  def ==(object)
    super || (object.is_a?(Tag) && name == object.name)
  end
  
  def to_s
    name
  end
  
  def count
    read_attribute(:count).to_i
  end
  
  # Renames to new_name. In the case that the new_name already exists it
  # re-associates all taggings, and destroys this tag.
  def rename!(new_name)
    if new_tag = Tag.find_by_name(new_name)
      transaction do
        taggings.update_all ['tag_id = ?', new_tag]
        destroy
      end
    else
      self.name = new_name
      self.save!
    end
  end
end
