if status is-interactive
    # Commands to run in interactive sessions can go here
end

function fish_prompt 
    /home/sergio/Repositories/ss_prompt/target/release/ss_prompt
end

alias ls="exa --icons=always -T -L 1"
alias cat="bat"
alias icat="kitten icat"
alias ssh="kitten ssh"
