class CreateTrips < ActiveRecord::Migration[6.0]
  def change
    create_table :trips do |t|
      t.string :city
      t.date :start_date
      t.date :end_date
      t.boolean :favourite, default: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
