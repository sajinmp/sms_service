class CreateAccount < ActiveRecord::Migration[6.1]
  def change
    create_table :account do |t|
      t.string :auth_id
      t.string :username
    end
  end
end
