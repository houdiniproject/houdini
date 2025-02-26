# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# from rails
require 'rails_helper'

describe 'CVE Test 2022-27777', type: :view do
  COMMON_DANGEROUS_CHARS = "&<>\"' %*+,/;=^|"
  it 'test_tag_builder_do_not_modify_html_safe_options' do
    html_safe_str = '"'.html_safe
    assert_equal "<p value=\"&quot;\" />", tag("p", value: html_safe_str)
    assert_equal '"', html_safe_str
    assert html_safe_str.html_safe?
  end

  it 'test_tag_with_dangerous_name' do
    assert_equal "<#{"_" * COMMON_DANGEROUS_CHARS.size} />",
                 tag(COMMON_DANGEROUS_CHARS)

    assert_equal "<#{COMMON_DANGEROUS_CHARS} />",
                 tag(COMMON_DANGEROUS_CHARS, nil, false, false)
  end

  #  not in Rails 4.2
  it 'test_tag_builder_with_dangerous_name' do
    escaped_dangerous_chars = "_" * COMMON_DANGEROUS_CHARS.size
    assert_equal "<#{escaped_dangerous_chars}></#{escaped_dangerous_chars}>",
                 tag.public_send(COMMON_DANGEROUS_CHARS.to_sym)

    assert_equal "<#{COMMON_DANGEROUS_CHARS}></#{COMMON_DANGEROUS_CHARS}>",
                 tag.public_send(COMMON_DANGEROUS_CHARS.to_sym, nil, escape: false)
  end

  it 'test_tag_with_dangerous_aria_attribute_name' do
    escaped_dangerous_chars = "_" * COMMON_DANGEROUS_CHARS.size
    assert_equal "<the-name aria-#{escaped_dangerous_chars}=\"the value\" />",
                 tag("the-name", aria: { COMMON_DANGEROUS_CHARS => "the value" })

    assert_equal "<the-name aria-#{COMMON_DANGEROUS_CHARS}=\"the value\" />",
                 tag("the-name", { aria: { COMMON_DANGEROUS_CHARS => "the value" } }, false, false)
  end
  
  # not in Rails 4.2
  it 'test_tag_builder_with_dangerous_aria_attribute_name' do
    escaped_dangerous_chars = "_" * COMMON_DANGEROUS_CHARS.size
    assert_equal "<the-name aria-#{escaped_dangerous_chars}=\"the value\"></the-name>",
                 tag.public_send(:"the-name", aria: { COMMON_DANGEROUS_CHARS => "the value" })

    assert_equal "<the-name aria-#{COMMON_DANGEROUS_CHARS}=\"the value\"></the-name>",
                 tag.public_send(:"the-name", aria: { COMMON_DANGEROUS_CHARS => "the value" }, escape: false)
  end

  it 'test_tag_with_dangerous_data_attribute_name' do
    escaped_dangerous_chars = "_" * COMMON_DANGEROUS_CHARS.size
    assert_equal "<the-name data-#{escaped_dangerous_chars}=\"the value\" />",
                 tag("the-name", data: { COMMON_DANGEROUS_CHARS => "the value" })

    assert_equal "<the-name data-#{COMMON_DANGEROUS_CHARS}=\"the value\" />",
                 tag("the-name", { data: { COMMON_DANGEROUS_CHARS => "the value" } }, false, false)
  end

  
  it 'test_tag_builder_with_dangerous_data_attribute_name' do 
    escaped_dangerous_chars = "_" * COMMON_DANGEROUS_CHARS.size
    assert_equal "<the-name data-#{escaped_dangerous_chars}=\"the value\"></the-name>",
                 tag.public_send(:"the-name", data: { COMMON_DANGEROUS_CHARS => "the value" })

    assert_equal "<the-name data-#{COMMON_DANGEROUS_CHARS}=\"the value\"></the-name>",
                 tag.public_send(:"the-name", data: { COMMON_DANGEROUS_CHARS => "the value" }, escape: false)
  end

  it 'test_tag_with_dangerous_unknown_attribute_name' do
    escaped_dangerous_chars = "_" * COMMON_DANGEROUS_CHARS.size
    assert_equal "<the-name #{escaped_dangerous_chars}=\"the value\" />",
                 tag("the-name", COMMON_DANGEROUS_CHARS => "the value")

    assert_equal "<the-name #{COMMON_DANGEROUS_CHARS}=\"the value\" />",
                 tag("the-name", { COMMON_DANGEROUS_CHARS => "the value" }, false, false)
  end

  # not in rails 4.2
  it 'test_tag_builder_with_dangerous_unknown_attribute_name' do
    escaped_dangerous_chars = "_" * COMMON_DANGEROUS_CHARS.size
    assert_equal "<the-name #{escaped_dangerous_chars}=\"the value\"></the-name>",
                 tag.public_send(:"the-name", COMMON_DANGEROUS_CHARS => "the value")

    assert_equal "<the-name #{COMMON_DANGEROUS_CHARS}=\"the value\"></the-name>",
                 tag.public_send(:"the-name", COMMON_DANGEROUS_CHARS => "the value", escape: false)
  end

  it 'test_tag_builder_with_content' do
    assert_equal "<div id=\"post_1\">Content</div>", content_tag("div", "Content", id: "post_1")
    assert_predicate content_tag("div","Content", id: "post_1"), :html_safe?
    assert_equal content_tag("div","Content", id: "post_1"),
                content_tag("div","Content", "id": "post_1")
    assert_equal "<p>&lt;script&gt;evil_js&lt;/script&gt;</p>",
                 content_tag("p","<script>evil_js</script>")
    assert_equal "<p><script>evil_js</script></p>",
                  content_tag("p","<script>evil_js</script>",  {}, false)
    assert_equal '<input pattern="\w+" />', tag('input', pattern: /\w+/)
  end

  it 'test_tag_builder_with_unescaped_array_class' do
    str = content_tag("p", "limelight", {class: ["song", "play>"]}, false)
    assert_equal "<p class=\"song play>\">limelight</p>", str

    str = content_tag("p","limelight", {class: ["song", ["play>"]]},  false)
    assert_equal "<p class=\"song play>\">limelight</p>", str
  end
end