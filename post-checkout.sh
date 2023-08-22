#!/bin/bash

# Store the previous and current commit refs
prev_commit="$1"
new_commit="$2"

# Get a list of Rails migration files that were added in prev_commit compared to
# new_commit.
prev_migrations=$(git diff --name-only --diff-filter=A "$new_commit".."$prev_commit" | grep db/migrate)

# Reverse-sort prev_migrations, to make sure we run the migrations in the
# correct order.
prev_migrations=$(echo "$prev_migrations" | sort -r)

# Exit early if there are no migrations to deal with.
if [ -z "$prev_migrations" ]; then
  exit 0
fi

# Ensure we're in the root directory of the project
root_directory=$(git rev-parse --show-toplevel)
pushd "$root_directory" >/dev/null || exit

# Loop through the previous migrations
for migration in $prev_migrations; do
  # Extract the migration version number
  migration_version=$(basename "$migration" | cut -d '_' -f 1)

  echo "Rolling back migration: $migration"

  # Temporarily restore the migration file to its original location
  git restore --source="$prev_commit" --worktree -- "$migration"

  # Rollback the migration. This safely no-ops if the migration has not yet
  # been run.
  bin/rails db:migrate:down VERSION="$migration_version"

  # Remove the temporarily checked out migration file
  rm "$migration"
done

# Switch back to the original working directory
popd >/dev/null || exit
