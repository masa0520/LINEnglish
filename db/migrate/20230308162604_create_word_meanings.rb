class CreateWordMeanings < ActiveRecord::Migration[7.0]
  def change
    create_table :word_meanings do |t|
      t.references :word, null: false, foreign_key: true
      t.references :meaning, null: false, foreign_key: true

      t.timestamps
    end
  end
end
