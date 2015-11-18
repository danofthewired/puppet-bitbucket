require 'spec_helper'

describe 'bitbucket::gc', :type => :class do
  context 'supported operating systems' do
    let(:pre_condition) { "class{'::bitbucket': }" }
    on_supported_os.each do |os, facts|
      context "on #{os} #{facts}" do
        let(:facts) do
          facts
        end
        regexp_lt  = %r{home/bitbucket/data/repositories}
        regexp_gte = %r{home/bitbucket/shared/data/repositories}

        file = '/usr/local/bin/git-gc.sh'

        it { should contain_file(file) }

        context 'with bitbucket version less than 3.2.0' do
          let(:facts) do
            facts.merge(:bitbucket_version => '3.1.99')
          end
          it do
            should contain_file(file)
              .with_content(regexp_lt)
          end
        end

        context 'with bitbucket version greater than 3.2.0' do
          it do
            should contain_file(file)
              .with_content(regexp_gte)
          end
        end

        context 'with bitbucket equal to 3.2' do
          let(:facts) do
            facts.merge(:bitbucket_version => '3.2.0')
          end
          it do
            should contain_file(file)
              .with_content(regexp_gte)
          end
        end
      end
    end
  end
end
