#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="${HOME}/harmonix/users"

if [ ! -d "$BASE_DIR" ]; then
  echo "Error: Directory '$BASE_DIR' not found." >&2
  exit 1
fi

echo "Setting up password hashes for all users in '$BASE_DIR'..."
echo "---------------------------------------------------------"

# Find all user subdirectories
for user_dir in "$BASE_DIR"/*/; do
  # Skip if no subdirectories exist
  [ -d "$user_dir" ] || continue

  # Extract the username from directory path
  username=$(basename "$user_dir")
  target_file="${user_dir}password.txt"

  # Ask if user already has a password file
  if [ -f "$target_file" ]; then
    read -rp "Password file already exists for '$username'. Overwrite? (y/N): " choice
    case "$choice" in
    [yY][eE][sS] | [yY]) ;;
    *)
      echo "Skipping '$username'."
      echo ""
      continue
      ;;
    esac
  fi

  echo "==> Enter password for user: $username"

  # Generate yescrypt hash using mkpasswd
  hash=$(nix-shell -p whois --run 'mkpasswd -m yescrypt')

  # Save the hash and secure permissions
  echo "$hash" >"$target_file"
  chmod 600 "$target_file"

  echo "Saved to $target_file"
  echo ""
done

echo "Done! All user passwords have been generated."
