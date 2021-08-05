class ChangeNullOnActivitiyTrip < ActiveRecord::Migration[6.0]
  def change
    change_column :activities, :trip_id, :bigint, null: true
  end
end
