require 'spec_helper.rb'

describe 'bitbucket' do
  describe 'bitbucket::backup' do
    context 'supported operating systems' do
      on_supported_os.each do |os, facts|
        context "on #{os} #{facts}" do
          let(:facts) do
            facts
          end
          let(:params) do
            { :manage_backup => false, }
          end

          context 'no install of bitbucket backup client' do
            it 'should not deploy bitbucket backup client' do
              should_not contain_archive("/tmp/bitbucket-backup-distribution-#{BACKUP_VERSION}.zip")
            end

            it 'should not manage the bitbucket-backup directories' do
              should_not contain_file('/opt/bitbucket-backup')
                .with('ensure' => 'directory')
            end
            it 'should not manage the backup cron job' do
              should_not contain_cron('Backup Bitbucket')
                .with('ensure'  => 'present',
                      'command' => "/usr/bin/java -Dbitbucket.password=\"password\" -Dbitbucket.user=\"admin\" -Dbitbucket.baseUrl=\"http://localhost:7990\" -Dbitbucket.home=/home/bitbucket -Dbackup.home=/opt/bitbucket-backup/archives -jar /opt/bitbucket-backup/bitbucket-backup-client-#{BACKUP_VERSION}/bitbucket-backup-client.jar",
                      'user'    => 'atlbitbucket',
                      'hour'    => '5',
                      'minute'  => '0',)
            end
          end
        end
      end
    end
  end
end
