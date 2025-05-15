# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe Controllers::ApiNew::JbuilderExpansions do
  describe "#handle_expansion" do
    def convert_to_json(tree)
      JSON.parse(tree)
    end
    let(:simple_object) {
      create(:simple_object_with_friends_and_parent)
    }
    context "when shrunk" do
      subject {
        convert_to_json(ApiNew::ApiController.render("api_new/simple_objects/show",
          assigns: {simple_object: simple_object,
                    __expand: Controllers::ApiNew::JbuilderExpansions::ExpansionTree.new}))
      }

      it {
        is_expected.to include("parent" => simple_object.parent.houid)
      }
    end

    context "when expanded" do
      subject {
        convert_to_json(ApiNew::ApiController.render("api_new/simple_objects/show",
          assigns: {
            simple_object: simple_object,
            __expand: Controllers::ApiNew::JbuilderExpansions::ExpansionTree.new("parent")
          }))
      }

      it {
        is_expected.to include("parent" => {
          "id" => simple_object.parent.houid,
          "parent" => simple_object.parent.parent.houid,
          "friends" => [],
          "friends_without_explicit_call" => [],
          "friends_no_block_given" => [],
          "object" => "simple_object",
          "nonprofit" => nil
        })
      }
    end

    context "when expanded twice" do
      subject {
        convert_to_json(ApiNew::ApiController.render("api_new/simple_objects/show",
          assigns: {
            simple_object: simple_object,
            __expand: Controllers::ApiNew::JbuilderExpansions::ExpansionTree.new("parent.parent")
          }))
      }

      it {
        is_expected.to include("parent" => {
          "id" => simple_object.parent.houid,
          "parent" => {
            "id" => simple_object.parent.parent.houid,
            "parent" => nil,
            "object" => "simple_object",
            "friends" => [],
            "friends_without_explicit_call" => [],
            "friends_no_block_given" => [],
            "nonprofit" => nil
          },
          "friends" => [],
          "friends_without_explicit_call" => [],
          "friends_no_block_given" => [],
          "object" => "simple_object",
          "nonprofit" => nil
        })
      }
    end
  end

  describe "#handle_array_expansion/#handle_item_expansion" do
    def convert_to_json(tree)
      JSON.parse(tree)
    end
    let(:simple_object) {
      create(:simple_object_with_friends_and_parent)
    }
    context "when shrunk" do
      subject {
        convert_to_json(ApiNew::ApiController.render("api_new/simple_objects/show",
          assigns: {simple_object: simple_object,
                    __expand: Controllers::ApiNew::JbuilderExpansions::ExpansionTree.new}))
      }

      it {
        is_expected.to include("friends" =>
            match_array(simple_object.friends.pluck(:houid)))
      }
    end

    context "when expanded" do
      subject {
        convert_to_json(ApiNew::ApiController.render("api_new/simple_objects/show",
          assigns: {
            simple_object: simple_object,
            __expand: Controllers::ApiNew::JbuilderExpansions::ExpansionTree.new("friends")
          }))
      }

      it {
        is_expected.to include("friends" =>
            match_array([
              {
                "id" => simple_object.friends.first.houid,
                "object" => "simple_object",
                "friends" => [],
                "friends_without_explicit_call" => [],
                "friends_no_block_given" => [],
                "parent" => nil,
                "nonprofit" => nil
              },
              {
                "id" => simple_object.friends.last.houid,
                "object" => "simple_object",
                "friends" => [],
                "friends_without_explicit_call" => [],
                "friends_no_block_given" => [],
                "parent" => simple_object.friends.last.parent.houid,
                "nonprofit" => nil
              }
            ]),
          "friends_without_explicit_call" => match_array(simple_object.friends.pluck(:houid)),
          "friends_no_block_given" => match_array(simple_object.friends.pluck(:houid)))
      }
    end

    context "when expanded once without passing a specific value to #handle_item_expansion" do
      subject {
        convert_to_json(ApiNew::ApiController.render("api_new/simple_objects/show",
          assigns: {
            simple_object: simple_object,
            __expand: Controllers::ApiNew::JbuilderExpansions::ExpansionTree.new("friends_without_explicit_call")
          }))
      }

      it {
        is_expected.to include("friends_without_explicit_call" =>
            match_array([
              {
                "id" => simple_object.friends.first.houid,
                "object" => "simple_object",
                "friends" => [],
                "friends_no_block_given" => [],
                "friends_without_explicit_call" => [],
                "parent" => nil,
                "nonprofit" => nil
              },
              {
                "id" => simple_object.friends.last.houid,
                "object" => "simple_object",
                "friends" => [],
                "friends_no_block_given" => [],
                "friends_without_explicit_call" => [],
                "parent" => simple_object.friends.last.parent.houid,
                "nonprofit" => nil
              }
            ]),
          "friends" => match_array(simple_object.friends.pluck(:houid)),
          "friends_no_block_given" => match_array(simple_object.friends.pluck(:houid)))
      }
    end

    context "when expanded once without no block given to #handle_array_expansion" do
      subject {
        convert_to_json(ApiNew::ApiController.render("api_new/simple_objects/show",
          assigns: {
            simple_object: simple_object,
            __expand: Controllers::ApiNew::JbuilderExpansions::ExpansionTree.new("friends_no_block_given")
          }))
      }

      it {
        is_expected.to include("friends_no_block_given" =>
            match_array([
              {
                "id" => simple_object.friends.first.houid,
                "object" => "simple_object",
                "friends" => [],
                "friends_without_explicit_call" => [],
                "friends_no_block_given" => [],
                "parent" => nil,
                "nonprofit" => nil
              },
              {
                "id" => simple_object.friends.last.houid,
                "object" => "simple_object",
                "friends" => [],
                "friends_without_explicit_call" => [],
                "friends_no_block_given" => [],
                "parent" => simple_object.friends.last.parent.houid,
                "nonprofit" => nil
              }
            ]),
          "friends" => match_array(simple_object.friends.pluck(:houid)),
          "friends_without_explicit_call" => match_array(simple_object.friends.pluck(:houid)))
      }
    end

    context "when expanded twice" do
      subject {
        convert_to_json(ApiNew::ApiController.render("api_new/simple_objects/show",
          assigns: {
            simple_object: simple_object,
            __expand: Controllers::ApiNew::JbuilderExpansions::ExpansionTree.new("friends.parent")
          }))
      }

      it {
        is_expected.to include_json("friends" =>
            match_array([
              {
                "id" => simple_object.friends.first.houid,
                "object" => "simple_object",
                "friends" => [],
                "friends_no_block_given" => [],
                "friends_without_explicit_call" => [],
                "parent" => nil,
                "nonprofit" => nil
              },
              {
                "id" => simple_object.friends.last.houid,
                "object" => "simple_object",
                "friends" => [],
                "friends_no_block_given" => [],
                "friends_without_explicit_call" => [],
                "parent" => {
                  "id" => simple_object.friends.last.parent.houid,
                  "object" => "simple_object",
                  "friends" => [],
                  "friends_no_block_given" => [],
                  "friends_without_explicit_call" => [],
                  "parent" => nil,
                  "nonprofit" => nil
                },
                "nonprofit" => nil

              }
            ]),
          "friends_without_explicit_call" => [simple_object.friends.first.houid, simple_object.friends.last.houid],
          "friends_no_block_given" => match_array(simple_object.friends.pluck(:houid)))
      }
    end
  end

  describe "::ExpansionTree" do
    def convert_to_json(expansion_request)
      JSON.parse(JSON.dump(expansion_request.root_node))
    end
    context "can be empty" do
      subject { convert_to_json(Controllers::ApiNew::JbuilderExpansions::ExpansionTree.new) }

      it {
        is_expected.to be_empty
      }
    end

    context "can have a single item" do
      subject { convert_to_json(Controllers::ApiNew::JbuilderExpansions::ExpansionTree.new("supporter")) }

      it {
        is_expected.to include_json(supporter: {})
      }
    end

    context "can have a multiple items at multiple levels" do
      subject { convert_to_json(Controllers::ApiNew::JbuilderExpansions::ExpansionTree.new("supporter", "transaction.subtransaction")) }

      it {
        is_expected.to include_json(supporter: {}, transaction: {subtransaction: {}})
      }
    end

    context "can safely have shorter paths that dont overload longer paths" do
      subject { convert_to_json(Controllers::ApiNew::JbuilderExpansions::ExpansionTree.new("supporter", "transaction.subtransaction", "transaction")) }

      it {
        is_expected.to include_json(supporter: {}, transaction: {subtransaction: {}})
      }
    end

    describe "#[]" do
      context "returns an empty ExpansionTree when no child with the given path exists" do
        subject { convert_to_json(Controllers::ApiNew::JbuilderExpansions::ExpansionTree.new("supporter")["transaction"]) }

        it {
          is_expected.to be_empty
        }
      end

      context "returns a child's ExpansionTree" do
        subject { convert_to_json(Controllers::ApiNew::JbuilderExpansions::ExpansionTree.new("supporter", "transaction.subtransaction")["transaction"]) }

        it {
          is_expected.to include_json({subtransaction: {}})
        }
      end

      context "keeps returning empty ExpansionTrees when none are available" do
        subject { convert_to_json(Controllers::ApiNew::JbuilderExpansions::ExpansionTree.new("transaction.subtransaction")["transaction"]["subtransaction"]["payments"]["charge"]) }

        it {
          is_expected.to include_json({})
        }
      end
    end

    describe "#expand?" do
      subject { Controllers::ApiNew::JbuilderExpansions::ExpansionTree.new("supporter", "transaction.subtransaction", "transaction") }

      it "returns false when a path should not be expanded" do
        is_expected.to_not be_expand "nonprofit"
      end

      it "returns true when a path should be expanded" do
        is_expected.to be_expand "supporter"
      end
    end
  end
end
