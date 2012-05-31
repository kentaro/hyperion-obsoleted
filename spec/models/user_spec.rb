require 'spec_helper'

describe User do
  describe 'before_save' do
    let(:user)  { create(:user) }
    let(:token) { user.token }
    subject { user }
    before  {
      token; # avoid lazy load
      user.save
    }

    it { subject.token.should_not == token }
  end

  describe 'find_or_create_from_auth_hash' do
    context 'when newly created' do
      before { User.delete_all }
      let(:user) {
        User.find_or_create_from_auth_hash(
          'provider' => 'github',
          'uid'      =>  1,
          'info'     => { 'nickname' => 'test' },
          'extra'    => { 'raw_info' => { 'avatar_url' => 'http://example.com/' } }
        )
      }
      subject { user }

      it { should_not be_nil }
      it { should be_an_instance_of User }
      it { subject.token.should_not be_nil }
    end

    context 'when user found' do
      before { @user = create(:user) }
      let(:found) {
        User.find_or_create_from_auth_hash(
          'provider' => @user.provider,
          'uid'      => @user.uid,
          'extra'    => { 'raw_info' => { 'avatar_url' => 'http://example.com/' } }
        )
      }
      subject { found }

      it { should_not be_nil }
      it { should == @user }
    end
  end

  describe 'shrink_avatar_url' do
    it 'should shrink gravatar url' do
      User.shrink_avatar_url('https://secure.gravatar.com/avatar/23f4d5d797a91b6d17d627b90b5a42d9?d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-140.png').should == '//gravatar.com/avatar/23f4d5d797a91b6d17d627b90b5a42d9'
    end
  end
end
