class CreateDomains < ActiveRecord::Migration[6.0]
  def change
    create_table :domains do |t|
      t.string :domain, index: true
      t.string :slug

      t.timestamps
    end
  end
end
