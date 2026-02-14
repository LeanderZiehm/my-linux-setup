#!/bin/bash

pacman -Qeq | xargs -r pacman -Qi > ./packages_data/extracted_explicitly_installed_packages.txt
pacman -Qq | xargs -r pacman -Qi > ./packages_data/extracted_all_installed_packages.txt



