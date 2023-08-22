# rails-git-helpers

Random helpers for working on a Rails app with Git.

## post-checkout.sh

A post-checkout hook; put it in `.git/hooks/post-checkout` in your Rails app.

When switching branches, it will roll back any migrations that only exist on the
previous branch.
