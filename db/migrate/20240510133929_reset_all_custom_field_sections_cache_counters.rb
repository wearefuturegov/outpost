class ResetAllCustomFieldSectionsCacheCounters < ActiveRecord::Migration[6.0]
  def up
    CustomFieldSection.all.each do |section|
      CustomFieldSection.reset_counters(section.id, :custom_fields)
    end
  end
  def down
    # no rollback needed
  end
end
