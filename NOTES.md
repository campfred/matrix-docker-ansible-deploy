# Notes

## Running the playbook with Doppler secrets

Run with these commands to get Doppler secrets as variables.

```shell
# Create a temporary file with lowercase keys
TEMP_VARS=$(mktemp)
doppler secrets download --format=json --no-file |
  jq 'walk(if type == "object" then with_entries(.key |= ascii_downcase) else . end)' > "$TEMP_VARS"

# Run ansible-playbook with the temporary file
ansible-playbook --extra-vars "@${TEMP_VARS}" --inventory inventory/hosts setup.yml --tags=setup-all,ensure-matrix-users-created,start

# Clean up
rm "$TEMP_VARS"
```

Or use the shell script.

```shell
./doppler-ansible-playbook.sh ${tags}
```

## Users registration

### Generating new registration tokens

Run the playbook with the `generate-matrix-registration-token` tag and with the `one_time` and `ex_date` variables set to define the token's expiration date and whether it can be used only once.

```shell
# Generate a registration token that can be used only once and expires on December 31, 2026
./doppler-ansible-playbook.sh generate-matrix-registration-token --extra-vars "one_time=yes ex_date=2026-12-31"
```

### Listing existing registration tokens

Run the playbook with the `list-matrix-registration-tokens` tag to list all existing registration tokens.

```shell
./doppler-ansible-playbook.sh list-matrix-registration-tokens
```
