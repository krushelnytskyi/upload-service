class UpdateUsers < ActiveRecord::Migration[5.1]
  def change
    change_table :users do |t|
      t.boolean :active, default: true
      t.string :role, default: :user
    end
  end
end
