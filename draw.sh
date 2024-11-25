#!/usr/bin/env bash

keymap -c ./keymap_drawer.config.yaml parse -z config/sofle.keymap > sofle.yaml
keymap -c ./keymap_drawer.config.yaml draw -j config/sofle.json sofle.yaml > sofle.svg
