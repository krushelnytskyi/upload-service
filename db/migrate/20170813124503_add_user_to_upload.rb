class AddUserToUpload < ActiveRecord::Migration[5.1]
  def change
    change_table :uploads do |t|
      t.integer :user_id
    end
  end
end
