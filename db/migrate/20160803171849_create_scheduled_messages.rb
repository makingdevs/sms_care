class CreateScheduledMessages < ActiveRecord::Migration
  def change
    create_table :scheduled_messages do |t| 
      t.column :body, :string, limit: 140
      t.column :status, :string, limit: 50
      t.column :phone_number, :string, limit: 15
      t.column :scheduled_date, :datetime
      t.column :uuid, :string, limit: 40
    end
  end
end
