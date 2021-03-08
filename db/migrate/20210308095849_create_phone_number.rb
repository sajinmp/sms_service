class CreatePhoneNumber < ActiveRecord::Migration[6.1]
  def change
    create_table :phone_number do |t|
      t.string :number
      t.integer :account_id
    end
  end
end
