class CreateLands < ActiveRecord::Migration[7.0]
  def change
    create_table :lands do |t|
      t.string :site
      t.string :site_path
      t.integer :price
      t.decimal :acreage
      t.string :city
      t.string :county
      t.string :state
      t.decimal :price_per_acre
      t.string :landwatch_id

      t.index :price_per_acre
      t.index :site_path, unique: true

      t.timestamps
    end
  end
end
