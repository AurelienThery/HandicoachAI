class CreateChatMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :chat_messages do |t|
      t.text :content
      t.string :role
      t.references :user, null: false, foreign_key: true
      t.references :routine, null: true, foreign_key: true

      t.timestamps
    end
  end
end
