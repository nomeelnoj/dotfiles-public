# Dotfiles

1. Create SSH key in temp location and upload to Github

    ```
    ssh-keygen -t ed25519 -f ~/ssh_temp -C 'Comment'
    cat ~/ssh_temp.pub | pbcopy
    ```

2. Install xcode tools: `xcode-select --install`

3. Install Rosetta: `softwareupdate --install-rosetta`

4. Disable SIP: Reboot, type `csrutil disable`

5. `sudo mkdir /usr/local/bin`; `sudo chown -R $USER:staff /usr/local/bin`

6. Clone dotfiles:

    ```
    mkdir -p $HOME/src/github.com/nomeelnoj
    GIT_SSH_COMMAND='ssh -i ~/ssh_temp' git clone git@github.com:nomeelnoj/dotfiles.git
    ```

7. Run bootstrap.sh


# Install Oh My Zsh

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
