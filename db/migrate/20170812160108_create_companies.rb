class CreateCompanies < ActiveRecord::Migration[5.1]
  def change
    create_table :companies do |t|
    	t.string :name
    	t.integer :user_id
    	t.boolean :active, default: true

      t.timestamps
    end
  end
end
