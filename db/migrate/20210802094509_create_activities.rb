class CreateActivities < ActiveRecord::Migration[6.0]
  def change
    create_table :activities do |t|
      t.string :picture_url
      t.string :name
      t.string :description
      t.time :duration
      t.string :link
      t.string :address
      t.float :latitude
      t.float :longitude
      t.boolean :favourite, default: false
      t.references :trip, null: false, foreign_key: true
      t.references :day, foreign_key: true

      t.timestamps
    end
  end
end
