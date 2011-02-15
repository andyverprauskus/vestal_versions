module VestalVersions
  # Allows specific versions to be version_tagged with a custom string. Useful for assigning a more
  # meaningful value to a version for the purpose of reversion.
  module VersionTagging
    extend ActiveSupport::Concern

    # Adds an instance method which allows version version_tagging through the parent object.
    module InstanceMethods
      # Accepts a single string argument which is attached to the version record associated with
      # the current version number of the parent object.
      #
      # Returns the given version_tag if successful, nil if not. Tags must be unique within the scope of
      # the parent object. Tag creation will fail if non-unique.
      #
      # Version records corresponding to version number 1 are not typically created, but one will
      # be built to house the given version_tag if the parent object's current version number is 1.
      def version_tag_version(version_tag)
        v = versions.at(version) || versions.build(:number => 1)
        v.version_tag!(version_tag)
      end
    end

    # Instance methods included into VestalVersions::Version to enable version version_tagging.
    module VersionMethods
      extend ActiveSupport::Concern

      included do
        validates_uniqueness_of :version_tag, :scope => [:versioned_id, :versioned_type], :if => :validate_version_tags?
      end

      # Attaches the given string to the version version_tag column. If the uniqueness validation fails,
      # nil is returned. Otherwise, the given string is returned.
      def version_tag!(version_tag)
        write_attribute(:version_tag, version_tag)
        save ? version_tag : nil
      end

      # Simply returns a boolean signifying whether the version instance has a version_tag value attached.
      def version_tagged?
        !version_tag.nil?
      end

      def validate_version_tags?
        version_tagged? && version_tag != 'deleted'
      end
    end

    Version.class_eval{ include VersionMethods }
  end
end
