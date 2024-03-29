class Word < ApplicationRecord
  belongs_to :user
  belongs_to :post
  has_many :word_meanings, dependent: :destroy
  has_many :meanings, through: :word_meanings
  has_many :word_memories, dependent: :destroy
end
