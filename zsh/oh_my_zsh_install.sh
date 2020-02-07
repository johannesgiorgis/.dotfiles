#!/usr/bin/env bash

###################################################################
#
# Install Oh My ZSH! - https://ohmyz.sh/
# ------------------
#
# Theme: Powerlevel10k
#
# Plugins:
#   - zsh-autosuggestions
#   - zsh-syntax-highlighting
#
###################################################################

echo -e "\nInstalling Oh My ZSH! and plugins..."

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Plugins

echo -e "\nInstalling 'powerlevel10k' theme..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k

echo -e "\nGetting 'zsh-autosuggestions' plugin..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

echo -e "\nGetting 'zsh-syntax-highlighting' plugin..."
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

echo -e "\nCompleted installing Oh My ZSH! and plugins!"
