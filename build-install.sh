#!/bin/sh

# for build and install easier to test in local
rm -f *.gem
gem build githook.gemspec
target=`ls *.gem`
gem install $target
