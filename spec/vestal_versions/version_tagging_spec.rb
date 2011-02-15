require 'spec_helper'

describe VestalVersions::VersionTagging do
  let(:user){ User.create(:name => 'Steve Richert') }

  before do
    user.update_attribute(:last_name, 'Jobs')
  end

  context 'an unversion_tagged version' do
    it "updates the version record's version_tag column" do
      version_tag_name = 'TAG'
      last_version = user.versions.last

      last_version.version_tag.should_not == version_tag_name
      user.version_tag_version(version_tag_name)
      last_version.reload.version_tag.should == version_tag_name
    end

    it 'creates a version record for an initial version' do
      user.revert_to(1)
      user.versions.at(1).should be_nil

      user.version_tag_version('TAG')
      user.versions.at(1).should_not be_nil
    end
  end

  context 'A version_tagged version' do
    subject{ user.versions.last }

    before do
      user.version_tag_version('TAG')
    end

    it { should be_version_tagged }
  end

end
