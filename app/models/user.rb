class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[facebook]
	has_many :posts
	has_many :comments
	has_many :likes, dependent: :destroy
 has_many :friend_sent, class_name: 'Friendship',
                          foreign_key: 'sent_by_id',
                          inverse_of: 'sent_by',
                          dependent: :destroy
    has_many :friend_request, class_name: 'Friendship',
                          foreign_key: 'sent_to_id',
                         inverse_of: 'sent_to',
                          dependent: :destroy
   has_many :friends, -> { merge(Friendship.friends) },
            through: :friend_sent, source: :sent_to
   has_many :pending_requests, -> { merge(Friendship.not_friends) },
            through: :friend_sent, source: :sent_to
   has_many :received_requests, -> { merge(Friendship.not_friends) },
            through: :friend_request, source: :sent_by
  has_many :notifications, dependent: :destroy
	#mount_uploader :image, ImageUploader
  validate :picture_size

   # Returns a string containing this user's first name and last name
  def full_name
    "#{first_name} #{last_name}"
  end
  
  # Returns all posts from this user's friends and self
  def friends_and_own_posts
    myfriends = friends
    our_posts = []
    myfriends.each do |f|
      f.posts.each do |p|
        our_posts << p
      end
    end
    posts.each do |p|
      our_posts << p
    end
    our_posts
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.first_name = auth.info.first_name # assuming the user model has a first name
      user.last_name = auth.info.last_name # assuming the user model has a last name
      #user.image = auth.info.image # assuming the user model has an image
      # If you are using confirmable and the provider(s) you use validate emails,
      # uncomment the line below to skip the confirmation emails.
      # user.skip_confirmation!
    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if (data = session['devise.facebook_data'] && session['devise.facebook_data']['extra']['raw_info'])
        user.email = data['email'] if user.email.blank?
      end
    end
  end
private
   # Validates the size of an uploaded picture.
    def picture_size
     #errors.add(:image, 'should be less than 1MB') if image.size > 1.megabytes
    end

end
