class CreateHosts < ActiveRecord::Migration
  def change
    create_table :hosts do |t|
      t.string :ip_address
      t.string :hostname

      t.timestamps
    end

    add_index :hosts, [:ip_address], unique: true
    add_index :hosts, [:hostname],   unique: true
  end
end
