set -o errexit

bundle lock --add-platform x86_64-linux
yarn install
bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean