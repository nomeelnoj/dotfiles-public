# Dotfiles

1. Allow using /usr/local/bin without sudo

    ```
    sudo mkdir /usr/local/bin
    sudo chown -R $USER:staff /usr/local/bin
    ```

2. Download the GH CLI (we will use it to upload our key), and create SSH key in temp location as we link our .ssh folder and will move the key in after.  We could do a lot better with this command with jq and others, but we dont have them yet...

    ```shell
    LATEST_VERSION=$(
      basename $(curl -Ls -o /dev/null -w %{url_effective} https://github.com/cli/cli/releases/latest)
    )
    curl -Lo \
      gh.tar.gz \
      https://github.com/cli/cli/releases/downloads/${LATEST_VERSION}/gh_${LATEST_VERSION##v}_macOS_arm64.zip
    unzip gh.zip
    mv gh_*/bin/gh /usr/local/bin/
    rm gh.zip
    rm -r gh_*_macOS_arm64
    ssh-keygen -t ed25519 -f ~/ssh_temp -C 'Comment'
    ```

3. Install xcode tools: `xcode-select --install`

4. Install Rosetta: `softwareupdate --install-rosetta`

5. Setup GH CLI

    ```
    gh auth login -s admin:public_key
    ```

    There is currently not a way with the GH CLI to create an API token, so you will still have to go into the github UI and create one, then set it in your `env` to allow GH CLI to work via Personal Access Token

6. Clone dotfiles:

    ```
    mkdir -p $HOME/src/github.com/nomeelnoj
    GIT_SSH_COMMAND='ssh -i ~/ssh_temp' git clone git@github.com:nomeelnoj/dotfiles.git
    ```

7. Run `./bootstrap.sh`


# Install Oh My Zsh

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
