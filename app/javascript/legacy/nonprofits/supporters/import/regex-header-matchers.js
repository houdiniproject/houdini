// License: LGPL-3.0-or-later

// A full list of available import keys that data can be imported into
// import_key roughly translates to 'table_name.column', but not exactly... see insert_imports.rb
// Also, the regexes allow us to automatically detect what CSV headers match what import keys
// 'regex' is the regex that we use to match on the CSV header
// 'name' is the readable name of the import key / table.column
// 'import_key' is a key name that is used to handle the importing of the data, found in insert_imports.rb

// Automatic header matching is performed top down -- the first regex to
// successfully match is used. So put the more generic matches at the bottom,
// below the more specific matches.

module.exports = [
  {
    regex: /.*e(-)?mail *(address)?.*/i
  , name: 'Donor Email'
  , import_key: 'supporter.email'
  }
  , {
    regex: /.*country.*/i
  , name: 'Donor Country'
  , import_key: 'supporter.country'
  }
  , {
    regex: /.*(street[ \-_]*)?address *(line[ \-_]*2).*/i
  , name: 'Donor Address (line 2)'
  , import_key: 'supporter.address_line2'
  }
  , {
    regex: /.*(street[ \-_]*)?address *(line[ \-_]*1)?.*/i
  , name: 'Donor Address (line 1)'
  , import_key: 'supporter.address'
  }
  , {
    regex: /.*city.*/i
  , name: 'Donor City'
  , import_key:'supporter.city'
  }
  , {
    regex: /.*(state|province)[ \-_]*(code)?.*/i
  , name: 'Donor State/Region'
  , import_key:'supporter.state_code'
  }
  , {
    regex: /.*(zip|postal)[ \-_]*(code)?.*/i
  , name: 'Donor Postal Code'
  , import_key:'supporter.zip_code'
  }
  , {
    regex: /.*(tele)?phone *(number)?.*/i
  , name: 'Donor Phone'
  , import_key:'supporter.phone'
  }
  , {
    regex: /.*(org|organization|company) *(name)?.*/i
  , name: 'Donor Company/Org'
  , import_key:'supporter.organization'
  }
  , {
    regex: /.*(donation|contributed)?[ \-_]*(amount|total).*/i
  , name: 'Donation Amount'
  , import_key:'donation.amount'
  }
  , {
    regex: /.*(fund|designation|towards).*/i
  , name: 'Donation Designation/Fund'
  , import_key:'donation.designation'
  }
  , {
    regex: /.*(campaign)[ \-_]*(name)?.*/i
  , name: 'Donation Campaign Name'
  , import_key:'donation.designation'
  }
  , {
    regex: /.*(honorarium|dedication|in honor of|memorium|in memory of).*/i
  , name: 'Donation Memorium/Dedication'
  , import_key:'donation.dedication'
  }
  , {
    regex: /.*((date)|(created(_at)?)).*/i
  , name: 'Donation Date'
  , import_key:'donation.date'
  }
  , {
    regex: /.*(payment)? *kind|type|method.*/i
  , name: 'Donation Payment Method'
  , import_key:'offsite_payment.kind'
  }
  , {
    regex: /.*comment|note(s?).*/i
  , name: 'Additional Note/Comment'
  , import_key:'donation.comment'
  }
  , {
    regex: /.*check.*/i
  , name: 'Check Number'
  , import_key:'offsite_payment.check_number'
  }
  , {
    regex: /.*tag.*/i
  , name: 'New Tag'
  , import_key:'tag'
  }
  , {
    regex: /.*(^ *(first[ \-_]*)?name).*/i
  , name: 'Donor First Name'
  , import_key:'supporter.first_name'
  }
  , {
    regex: /.*(^ *(last[ \-_]*)?name).*/i
  , name: 'Donor Last Name'
  , import_key:'supporter.last_name'
  }
  , {
    regex: /.*(full[ \-_]*)?name.*/i
  , name: 'Donor Full Name'
  , import_key:'supporter.name'
  }
]

