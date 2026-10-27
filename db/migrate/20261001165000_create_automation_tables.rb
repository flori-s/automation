# frozen_string_literal: true

class CreateAutomationTables < ActiveRecord::Migration[6.1]
  def up
    json_type = connection.adapter_name.match?(/postgres/i) ? :jsonb : :json

    create_table :automation_rules do |t|
      t.string :name, null: false
      t.string :target_type, null: false
      t.string :key
      t.boolean :enabled, null: false, default: true
      t.column :trigger, json_type, null: false, default: {}
      t.column :action, json_type, null: false, default: {}
      t.column :cancel_conditions, json_type, null: false, default: {}
      t.timestamps
    end
    add_index :automation_rules, :key, unique: true
    add_index :automation_rules, %i[target_type enabled]

    create_table :automation_jobs do |t|
      t.references :automation_rule, null: false, foreign_key: true
      t.string :target_type, null: false
      t.bigint :target_id, null: false
      t.datetime :run_at, null: false
      t.string :status, null: false, default: "pending"
      t.string :idempotency_key, null: false
      t.datetime :executed_at
      t.text :error_message
      t.integer :attempts, null: false, default: 0
      t.timestamps
    end
    add_index :automation_jobs, :idempotency_key, unique: true
    add_index :automation_jobs, %i[status run_at]
    add_index :automation_jobs, %i[target_type target_id]
    add_index :automation_jobs, %i[automation_rule_id target_type target_id],
              name: "index_automation_jobs_on_rule_and_target"
  end

  def down
    drop_table :automation_jobs
    drop_table :automation_rules
  end
end
