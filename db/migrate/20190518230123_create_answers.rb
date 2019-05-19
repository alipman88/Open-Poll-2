class CreateAnswers < ActiveRecord::Migration[6.0]
  def change
    create_table :answers do |t|
      t.references :question, null: false, foreign_key: true
      t.string :field_value
      t.string :caption
      t.boolean :show_on_ballot
      t.boolean :show_in_results
      t.text :description

      t.timestamps
    end
  end
end
