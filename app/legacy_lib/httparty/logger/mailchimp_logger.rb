# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
#
# based on https://github.com/jnunemaker/httparty/blob/b8f769e9f3133ec1dfa7fb2800ff3542d4248099/lib/httparty/logger/curl_formatter.rb which is
# under the following license:
# Copyright (c) 2008 John Nunemaker

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
module HTTParty
  module Logger
    class MailchimpLogger < ::HTTParty::Logger::CommitchangeLogger
      def initialize(logger, level)
        super(logger, level, "mailchimp")
      end
    end
  end
end
