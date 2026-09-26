# Fake HOME for the demo GIF. It is sourced by demo.tape, so it can change
# HOME, PS1 and the aliases of the recording shell.
# Nothing outside /tmp/dotfiles-demo is touched.

repo_dir=$(realpath "$(dirname "${BASH_SOURCE[0]}")/..")
demo_home=/tmp/dotfiles-demo

rm -rf "$demo_home"
mkdir -p "$demo_home/.dotfiles"
# Copy (not symlink) the tracked files, so Stow prints short relative links
git -C "$repo_dir" ls-files -z | (cd "$repo_dir" && xargs -0 cp --parents -t "$demo_home/.dotfiles")

export HOME="$demo_home"
export PS1='\[\e[1;34m\]\w\[\e[0m\] \[\e[1;32m\]$\[\e[0m\] '
unset XDG_CONFIG_HOME

# Same aliases as bash/.bashrc
alias ls='eza --icons=auto --group-directories-first --classify=auto'
alias ll='eza -l --icons=auto --group-directories-first --no-permissions --no-user --no-time --no-filesize --classify=auto'
alias lt='eza --tree --level=2 --icons=auto --classify=auto'

cd "$HOME/.dotfiles" || return
