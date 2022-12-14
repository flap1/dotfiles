#!/bin/bash

# dvm: deno version management
mkdir ~/.dvm
curl -fsSL https://dvm.deno.dev | sh
dvm install
dvm use

