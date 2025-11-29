
### Recommended Configuration 1: Minimalist Modern Style (Suitable for Terminal Enthusiasts)
```bash
# Minimal Modern PS1 (white + blue + green)
PS1='\[\e[38;5;255m\]\u\[\e[38;5;33m\]@\[\e[38;5;46m\]\h\[\e[38;5;245m\]:\[\e[38;5;111m\]\w\[\e[38;5;255m\]$(__git_ps1 " (%s)")\[\e[38;5;255m\]\$\[\e[0m\] '
```

#### Effect Description:

- Username (white) @ Hostname (blue): Working directory (dark green)
- Git branch (white, in parentheses, only displayed in Git repositories)
- Permission symbol: `$` for regular users (white) / `#` for root (automatically adapts to red)
- Low-saturation color scheme, not dazzling, suitable for long-term use

## Recommended Configuration 2: Feature-Rich Style (Suitable for Developers / Operations)

#### Effect Description:

- Left timestamp (cyan, `HH:MM:SS` format, convenient for log tracing)
- Username (bright green) @ Hostname (bright blue): Working directory (bright purple)
- Git branch (bright cyan, in square brackets)
- Permission symbol: `#` for root (bright red), `$` for regular users (bright red)
- All text is bold, with a strong sense of hierarchy and high information density

```bash
# Feature-Rich PS1 (with timestamp + Git status + permission)
PS1='\[\e[1;37m\][\[\e[0;36m\]\D{%H:%M:%S}\[\e[1;37m\]] \[\e[1;32m\]\u\[\e[1;33m\]@\[\e[1;34m\]\h\[\e[1;37m\]:\[\e[1;35m\]\w\[\e[1;36m\]$(__git_ps1 " [%s]")\[\e[1;31m\]$([[ $EUID -eq 0 ]] && echo "#" || echo "$")\[\e[0m\] '
```

## Recommended Configuration 3: Retro Terminal Style (Suitable for Users Who Like Nostalgic Styles)

```bash
# Retro Terminal PS1 (amber + cyan + dark gray)
PS1='\[\e[38;5;214m\]\u\[\e[38;5;87m\]@\[\e[38;5;231m\]\h\[\e[38;5;156m\]:\[\e[38;5;241m\]\W\[\e[38;5;87m\]$(__git_ps1 " <%s>")\[\e[38;5;214m\]\$\[\e[0m\] '
```

#### Effect Description:

- Username (amber) @ Hostname (white): Working directory (short path, light orange)
- Git branch (cyan, in angle brackets)
- Permission symbol (amber)
- Color scheme imitates old-fashioned terminals, low saturation, full of retro feeling
- Path uses `\W` (only shows current directory name), suitable for long path scenarios

## Recommended Configuration 4: Display Time and Current Working Directory


```bash
# Clean Professional PS1 (time + user@host + full path)
PS1='\[\e[38;5;144m\]\D{%H:%M:%S}\[\e[0m\] \[\e[38;5;46m\]\u\[\e[38;5;255m\]@\[\e[38;5;33m\]\h\[\e[38;5;245m\]:\[\e[38;5;111m\]\w\[\e[38;5;255m\]\$\[\e[0m\] '
```

#### Effect Description:

- Timestamp (light cyan, `HH:MM:SS` format) + Username (green) @ Hostname (blue): Full path (dark green)
- Permission symbol: `$` for regular users (pure white) / `#` for root (automatically turns red)
- Low-saturation color scheme, not dazzling, clear information hierarchy, suitable for long-term office work / operations

## Custom Modification Guide:

- Change colors: Modify `XXX` in `\e[38;5;XXXm` (use [ANSI 256 Color Code Table](https://www.lihaoyi.com/post/BuildyourownCommandLinewithANSIescapecodes.html#256-colors))
    - Examples: `38;5;255m` = white, `38;5;46m` = green, `38;5;196m` = red
- Adjust format:
    - `\u` = username, `\h` = hostname, `\w` = full path, `\W` = simplified path
    - `\D{%H:%M:%S}` = timestamp, can be changed to `\D{%Y-%m-%d %H:%M}` to display date
- Remove Git branch: Delete the `$(__git_ps1 " (%s)")` part

## How to Make It Effective?

1. Open the Bash configuration file:
    ```bash
    vim ~/.bashrc
    ```
    
2. Scroll to the end of the file and paste any of the above PS1 configurations (choose one)
    
3. Save and exit (press `ESC` then enter `:wq`)
    
4. Take effect immediately (no need to restart the terminal):
    ```bash
    source ~/.bashrc
    ```