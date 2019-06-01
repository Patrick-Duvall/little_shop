class CreateAddresses < ActiveRecord::Migration[5.1]
  def change
    create_table :addresses do |t|
      t.string :nick_name
      t.string :address
      t.string :city
      t.string :state
      t.string :zip
      t.references :user, foreign_key: true
    end
  end
end
