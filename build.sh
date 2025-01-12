#!/bin/bash

# Install PostgreSQL client libraries
apt-get update && apt-get install -y libpq-dev

# Install YAML libraries
apt-get install -y libyaml-dev

# Run bundle install
bundle install