class Word < ApplicationRecord
  belongs_to :english_word
  belongs_to :japanese_word
  belongs_to :post
end
