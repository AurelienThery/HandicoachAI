class CreateRoutines < ActiveRecord::Migration[7.1]
  def change
    create_table :routines do |t|
      t.string :title
      t.text :description
      t.text :steps
      t.string :visibility
      t.references :user, null: false, foreign_key: true
      t.text :shared_with_ids

      t.timestamps
    end
  end
end
