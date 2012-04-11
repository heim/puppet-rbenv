require 'spec_helper'

describe 'rbenv' do
  let(:title) { 'rbenv' }
  let(:params) { { :user => 'tester', :shell => "zsh" } }

  it { should include_class('rbenv::dependencies') }

end
