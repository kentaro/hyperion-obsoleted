require 'spec_helper'

describe Service do
  describe "attrs" do
    subject { Service.new(:name => 'test', :description => 'test')}

    [:name, :description].each do |attr|
      it { should respond_to attr }
    end
  end
end
