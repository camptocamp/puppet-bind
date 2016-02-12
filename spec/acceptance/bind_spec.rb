require 'spec_helper_acceptance'

describe 'bind' do

  context 'with defaults' do
    it 'should apply without error' do
      pp = <<-EOS
        class { 'bind': }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end
    it 'should idempotently run' do
      pp = <<-EOS
        class { 'bind': }
      EOS

      apply_manifest(pp, :catch_changes => true)
    end
    it 'should idempotently run bis' do
      pp = <<-EOS
        class { 'bind': }
      EOS
      apply_manifest(pp, :catch_changes => true)
    end
  end
end
