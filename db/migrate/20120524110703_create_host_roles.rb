class CreateHostRoles < ActiveRecord::Migration
  def change
    create_table :host_roles do |t|
      t.integer :host_id
      t.integer :role_id

      t.timestamps
    end

    add_index :host_roles, [:host_id]
    add_index :host_roles, [:role_id]
    add_index :host_roles, [:role_id, :host_id], unique: true
  end
end
