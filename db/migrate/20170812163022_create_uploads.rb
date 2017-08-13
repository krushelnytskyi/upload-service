class CreateUploads < ActiveRecord::Migration[5.1]
  def change
    create_table :uploads do |t|
      t.integer :year
      t.integer :company_id
      t.integer :size
      t.string :path
      t.timestamps
    end
  end
end
