# Based on evan's prompt
# Shows the exit status of the last command if non-zero
# Uses "#" instead of "»" when running with elevated privileges
PROMPT='$fg_bold[blue][ $fg[red]%w @ %T $fg_bold[blue]] $fg_bold[blue][ $fg_bold[yellow]DevOne $fg_bold[blue]] $fg_bold[blue] [ $fg[red]%~:$(git_prompt_info)$fg[yellow]$(rvm_prompt_info)$fg_bold[blue] ]$reset_color
 ~~~> '
