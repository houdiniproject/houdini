# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"
# rubocop:disable RSpec/VerifiedDoubles, RSpec/MessageSpies regular doubles work fine in this use-case
RSpec.describe Model::Houidable do
  let(:houid_test_class) do
    Class.new do
      include ActiveModel::AttributeAssignment
      include ActiveModel::Model
      extend ActiveModel::Callbacks
      include Model::Houidable

      attr_accessor :id, :houid_id

      define_model_callbacks :initialize
      define_model_callbacks :save
      def initialize(attributes = {})
        run_callbacks :initialize do
          assign_attributes(attributes)
        end
      end

      def save
        run_callbacks :save do
          # run save
        end
      end

      # mock for read and write attributes
      def read_attribute(attr_name)
        send(attr_name.to_sym)
      end

      def write_attribute(attr_name, value)
        send(:"#{attr_name}=", value)
      end
    end
  end

  context "when using the default :id attribute" do
    let(:test_class) do
      Class.new(houid_test_class) do
        setup_houid :trxassign
      end
    end

    let(:with_before_set_callback) do
      Class.new(test_class) do
        mattr_accessor :callback_handler
        before_houid_set ->(model) { self.class.callback_handler.before_houid_set_callback(model) }
      end
    end

    let(:with_after_set_callback) do
      Class.new(test_class) do
        mattr_accessor :callback_handler
        after_houid_set ->(model) { self.class.callback_handler.after_houid_set_callback(model) }
      end
    end

    let(:prefix) { :trxassign }
    let(:preset_houid) { "test_eoiathotih" }

    let(:default_trxassign) { test_class.new }

    let(:already_set_houid) { test_class.new(id: preset_houid) }

    it "sets houid_prefix" do
      expect(default_trxassign.houid_prefix).to eq prefix
    end

    it "generates a valid houid" do
      expect(default_trxassign.generate_houid).to match_houid(prefix)
    end

    context "when only initialized" do
      it "doesnt set a houid" do
        expect(default_trxassign.id).to be_nil
      end

      it "will not override an id if already set" do
        expect(already_set_houid.id).to eq preset_houid
      end

      it "will not fire the before_houid_set callback" do
        with_before_set_callback.callback_handler = double("Before Callback Handler")
        expect(with_before_set_callback.callback_handler).to_not receive(:before_houid_set_callback)
        with_before_set_callback.new
      end

      it "will not fire the after_houid_set callback" do
        with_after_set_callback.callback_handler = double("After Callback Handler")
        expect(with_after_set_callback.callback_handler).to_not receive(:after_houid_set_callback)
        with_after_set_callback.new
      end
    end

    context "when saved" do
      it "generates a valid houid" do
        default_trxassign.save
        expect(default_trxassign.id).to match_houid(prefix)
      end

      it "will not override an id if already set" do
        already_set_houid.save
        expect(already_set_houid.id).to eq preset_houid
      end

      it "fires the before_houid_set callback" do
        with_before_set_callback.callback_handler = double("Before Callback Handler")
        expect(with_before_set_callback.callback_handler).to receive(:before_houid_set_callback).with(
          having_attributes(id: nil)
        )
        with_before_set_callback.new.save
      end

      it "fires the after_houid_set callback" do
        with_after_set_callback.callback_handler = double("After Callback Handler")
        expect(with_after_set_callback.callback_handler).to receive(:after_houid_set_callback).with(
          having_attributes(id: match_houid(:trxassign))
        )
        with_after_set_callback.new.save
      end
    end
  end

  context "when using a custom attribute" do
    let(:test_class) do
      Class.new(houid_test_class) do
        setup_houid "trxassign", "houid_id"
      end
    end

    let(:with_before_set_callback) do
      Class.new(test_class) do
        mattr_accessor :callback_handler
        before_houid_set ->(model) { self.class.callback_handler.before_houid_set_callback(model) }
      end
    end

    let(:with_after_set_callback) do
      Class.new(test_class) do
        mattr_accessor :callback_handler
        after_houid_set ->(model) { self.class.callback_handler.after_houid_set_callback(model) }
      end
    end

    let(:prefix) { :trxassign }
    let(:preset_houid) { "test_eoiathotih" }

    let(:default_trxassign) { test_class.new }

    let(:already_set_houid) { test_class.new(houid_id: preset_houid) }

    it "sets houid_prefix" do
      expect(default_trxassign.houid_prefix).to eq prefix
    end

    it "generates a valid houid" do
      expect(default_trxassign.generate_houid).to match_houid(prefix)
    end

    context "when only initialized" do
      it "does not set a houid" do
        expect(default_trxassign.houid_id).to be_nil
      end

      it "will not override an id if already set" do
        expect(already_set_houid.houid_id).to eq preset_houid
      end

      it "will not fire the before_houid_set callback" do
        with_before_set_callback.callback_handler = double("Before Callback Handler") # rubocop:disable RSpec/VerifiedDoubles
        expect(with_before_set_callback.callback_handler).to_not receive(:before_houid_set_callback)
        with_before_set_callback.new
      end

      it "will not fire the after_houid_set callback" do
        with_after_set_callback.callback_handler = double("After Callback Handler") # rubocop:disable RSpec/VerifiedDoubles
        expect(with_after_set_callback.callback_handler).to_not receive(:after_houid_set_callback)
        with_after_set_callback.new
      end
    end

    context "when saved" do
      it "sets a valid houid as id" do
        default_trxassign.save
        expect(default_trxassign.houid_id).to match_houid(prefix)
      end

      it "will not override an id if already set" do
        already_set_houid.save
        expect(already_set_houid.houid_id).to eq preset_houid
      end

      it "fires the before_houid_set callback" do
        with_before_set_callback.callback_handler = double("Before Callback Handler") # rubocop:disable RSpec/VerifiedDoubles
        expect(with_before_set_callback.callback_handler).to receive(:before_houid_set_callback).with(
          having_attributes(houid_id: nil)
        )
        with_before_set_callback.new.save
      end

      it "fires the after_houid_set callback" do
        with_after_set_callback.callback_handler = double("After Callback Handler") # rubocop:disable RSpec/VerifiedDoubles
        expect(with_after_set_callback.callback_handler).to receive(:after_houid_set_callback).with(
          having_attributes(houid_id: match_houid(:trxassign))
        )
        with_after_set_callback.new.save
      end
    end
  end
end
# rubocop:enable RSpec/VerifiedDoubles, RSpec/MessageSpies
