class ChangeNullOnTripUser < ActiveRecord::Migration[6.0]
  def change
    change_column :trips, :user_id, :bigint, null: true
  end
end
