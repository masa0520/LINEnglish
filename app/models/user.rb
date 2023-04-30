class User < ApplicationRecord
  authenticates_with_sorcery!

  validates :name, presence: true
  validates :email, uniqueness: true
  validates :email, presence: true
  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }

  has_one_attached :image
  has_many :words
  has_many :meanings
  has_many :posts
  has_many :bookmarks, dependent: :destroy
  #user.bookmarks.map(&:post)と同義user.bookmarks.map(&:post)
  has_many :bookmark_posts, through: :bookmarks, source: :post
  has_many :word_memories, dependent: :destroy
  has_many :line_posts, dependent: :destroy
  has_many :line_relations, through: :line_posts, source: :post
  
  def bookmark?(post)
    bookmark_posts.include?(post)
  end

  def line_relation?(post)
    line_relations.include?(post)
  end

end
