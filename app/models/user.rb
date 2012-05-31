class User < ActiveRecord::Base
  attr_accessible :provider, :uid, :name, :image
  before_save :update_token

  class << self
    def find_or_create_from_auth_hash(hash)
      user = find_by_provider_and_uid(hash['provider'], hash['uid']) || create(
        provider: hash['provider'],
        uid:      hash['uid'],
        name:     hash['info']['nickname'],
      )

      # image can be updated every time
      user.image = shrink_avatar_url(hash['extra']['raw_info']['avatar_url'])
      user
    end

    def shrink_avatar_url(avatar_url)
      avatar_url.sub(/^https:/, '').sub(/^(\/\/)secure\./, '\1').sub(/\?.+$/, '')
    end
  end

  protected

  def update_token
    self.token = SecureRandom.urlsafe_base64
  end
end
