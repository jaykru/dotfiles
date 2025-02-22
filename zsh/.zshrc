export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000000
export SAVEHIST=10000000
export PASSWORD_STORE_ENABLE_EXTENSIONS=true

if [[ "$USER" = "ubuntu" || $(hostname) =~ "n300" || $(hostname) =~ "n150" ]]; then
  source ~/.ttrc
fi

GUIX_PROFILE="/var/guix/profiles/per-user/$USER/guix-profile/etc/profile"
if [[ -f $GUIX_PROFILE ]]; then
   . "$GUIX_PROFILE"
fi

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk
zinit ice lucid wait'0'
# Two regular plugins loaded without investigating.
zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting

zinit light joshskidmore/zsh-fzf-history-search

# Binary release in archive, from GitHub-releases page.
# After automatic unpacking it provides program "fzf".
zi ice from"gh-r" as"program"
zi light junegunn/fzf

autoload -Uz compinit
compinit
zinit load Aloxaf/fzf-tab 
zinit light spaceship-prompt/spaceship-prompt

SPACESHIP_PROMPT_ORDER=(
  dir           # Current directory
  git           # Git section (git_branch + git_status)
  char          # Prompt character
)


zinit light zsh-users/zsh-completions

# direnv
zinit from"gh-r" as"program" mv"direnv* -> direnv" \
atclone'./direnv hook zsh > zhook.zsh' atpull'%atclone' \
pick"direnv" src="zhook.zsh" for \
direnv/direnv
