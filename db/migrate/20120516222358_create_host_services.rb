class CreateHostServices < ActiveRecord::Migration
  def change
    create_table :host_services do |t|
      t.integer :host_id
      t.integer :service_id

      t.timestamps
    end

    add_index [:host_id]
    add_index [:service_id]
  end
end
