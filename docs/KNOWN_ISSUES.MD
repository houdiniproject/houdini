## Byebug or Pry won't start - image not found readline.bundle
----------
```bash
pry
# Sorry, you can't use byebug without Readline. To solve this, you need to
# rebuild Ruby with Readline support. If using Ubuntu, try `sudo apt-get
# install libreadline-dev` and then reinstall your Ruby.
```

I use rvm to manage my ruby versions. You can use rvm to recompile ruby from source to solve the problem. There are a few other work arounds as well, but this seemed like the correct solution and it worked for me.

Sounds like we should generally rebuild ruby as a best practice after macOS upgrades. In this case it was macOS Mojave + brew updates that triggered this new awareness for me.

### Steps to rebuild ruby via **RVM**
It's a good idea to make sure you've installed the latest Xcode + tools before proceeding; check App Store for updates. Be sure to accept the Xcode License before proceeding!

Update Xcode and accept the license:
* Update Xcode to latest via App Store, be sure to update the Xcode Tools as well.
* In a terminal window, exec this command: sudo xcodebuild -license accept

Make sure you have the **readline** lib installed:

* `brew --prefix readline`
* if you get Error: No available formula with the name "readline", install readline:
  * `brew install readline`
  * `brew link --force readline` You'll need to use `--force` to make it work.
  * `vi ~/.rvm/user/db` and add the following: `ruby_configure_flags=--with-readline-dir=/usr/local/opt/readline`

Reinstall Ruby, with a rebuild of sources:

* `rvm reinstall <your_ruby_version>` This command removes the specified version's ruby binaries and libs, and rebuilds from source code on your system, with the latest macOS headers and libs.
* `rvm reinstall <your_ruby_version> --gems` This command repro's the same steps as above, but it removes the gems first as well. The next time you run bundle install the gems will be downloaded and rebuilt against your latest ruby. This can help resolve other potential issues with gems after rebuilding ruby on macOS.
* Change the specified version (2.5.1 in my case) to match your needs.
* **I ended up using the second syntax for a completely fresh start.**

#### After completing these steps I did two more things:

Since I happened to be in a project directory in a terminal window when I started this process, I had to `cd ..` up a level and then `cd project-folder` back into my project so that RVM would reactivate my gemset.
I ran `gem install bundler` and then `bundle install` to re-hydrate the gems for my project.
and then I was good to go again.
