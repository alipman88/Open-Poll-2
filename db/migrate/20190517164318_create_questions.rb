class CreateQuestions < ActiveRecord::Migration[6.0]
  def change
    create_table :questions do |t|
      t.references :poll, null: false, foreign_key: true
      t.integer :position, limit: 1, index: true
      t.string :slug, index: true
      t.string :field_name
      t.string :question, limit: 511

      t.timestamps
    end
  end
end
