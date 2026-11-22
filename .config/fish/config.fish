if status is-interactive
    set -g fish_greeting
    # Commands to run in interactive sessions can go here
end

# --- ALIASES -------------------------------------------

alias ls 'eza --icons auto'
alias tree 'eza --tree -L 2 --ignore-glob=.git'
alias y yazi
alias sy 'sudo yazi'
alias torlink 'npx torlnk'
alias ipad 'od-sender run'
alias shizukuadb 'adb shell /data/app/~~UzNTLP-vI-XMWVtF_84gTQ==/moe.shizuku.privileged.api-Ja9g96abFLFbbsYeQeHXYw==/lib/arm64/libshizuku.so'

alias matrix 'cmatrix -s 96 -C white'
alias ff fastfetch
alias typtea 'typtea start --duration 60 --lang'
alias neofetch fastfetch
alias lgit lazygit

alias audiofix 'wireplumber & disown'

alias cppformatgoogle '~/.local/share/nvim/mason/bin/clang-format --style Google --dump-config > .clang-format'
alias cppformatGNU '~/.local/share/nvim/mason/bin/clang-format --style GNU --dump-config > .clang-format'

alias hyprconf 'nvim ~/.config/hypr/modules/'
alias nvimconf 'nvim ~/.config/nvim/'
alias dotsconf 'nvim ~/SertralineDots/.config'

alias neorg 'cd ~/Notes/ & nvim'

alias i2prouter '~/i2p/i2prouter'

set -x EDITOR nvim

# Created by `pipx` on 2026-05-08 04:23:43
set PATH $PATH ~/.local/bin

#yazi
function yazi
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    command yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end
