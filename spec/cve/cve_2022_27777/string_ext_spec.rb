# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# from rails
require 'rails_helper'

describe 'CVE Test 2022-27777' do 

  it "ERB::Util.xml_name_escape should escape unsafe characters for XML names" do
    unsafe_char = ">"
    safe_char = "Á"
    safe_char_after_start = "3"

    assert_equal "_", ERB::Util.xml_name_escape(unsafe_char)
    assert_equal "_#{safe_char}", ERB::Util.xml_name_escape(unsafe_char + safe_char)
    assert_equal "__", ERB::Util.xml_name_escape(unsafe_char * 2)

    assert_equal "__#{safe_char}_",
                ERB::Util.xml_name_escape("#{unsafe_char * 2}#{safe_char}#{unsafe_char}")

    assert_equal safe_char + safe_char_after_start,
                ERB::Util.xml_name_escape(safe_char + safe_char_after_start)

    assert_equal "_#{safe_char}",
                ERB::Util.xml_name_escape(safe_char_after_start + safe_char)

    assert_equal "img_src_nonexistent_onerror_alert_1_",
                ERB::Util.xml_name_escape("img src=nonexistent onerror=alert(1)")

    common_dangerous_chars = "&<>\"' %*+,/;=^|"
    assert_equal "_" * common_dangerous_chars.size,
                ERB::Util.xml_name_escape(common_dangerous_chars)
   end
end