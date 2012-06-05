require 'spec_helper'

describe "Role Pages" do
  context "When users" do
    let(:role) { create(:role) }
    subject { page }

    describe "new_role_page" do
      context "when `return_to' query not exists" do
        let(:role_name) { "Test Role #{rand(2**32)}" }

        before {
          visit new_role_path
          fill_in 'Name',        with: role_name
          fill_in 'Description', with: 'desc for role'
          click_button 'Create Role'
        }

        it { should have_selector('h1', text: 'Role') }
      end

      context "when `return_to' query exists" do
        let(:role_name) { "Test Role #{rand(2**32)}" }

        before {
          visit new_role_path(return_to: '/')
          fill_in 'Name',        with: role_name
          fill_in 'Description', with: 'desc for role'
          click_button 'Create Role'
        }

        it { should have_selector('h1', text: 'Services') }
      end
    end
  end

  context "When guests" do
  end
end
