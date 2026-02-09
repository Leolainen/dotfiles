#!/bin/bash
ghostty_theme=$(ghostty +show-config | grep theme | awk '{print $3}')
# get palette from built in themes
palette=$(cat /Applications/Ghostty.app/Contents/Resources/ghostty/themes/$ghostty_theme)

# get palette from custom themes if not found in built in themes
if [ -z "$palette" ]; then
    palette=$(cat ~/.config/ghostty/themes/$ghostty_theme)
fi

# Something went wrong
if [ -z "$palette" ]; then
    echo "Theme not found"
    exit 1
fi

file="$HOME/.config/sketchybar/palette.sh"

# recreate palette.sh file with the new palette
rm -f $file
touch $file
echo "$palette" >>$file

formattedPalette=""
paletteArr=()

while read -r line; do
    [[ -z "$line" || "$line" == \#* ]] && continue # Skip comments/empty lines

    key=$(echo "$line" | awk -F '=' '{print $1}' | sed 's/-/_/g' | xargs)
    value=$(echo "$line" | awk -F '=' '{print substr($0, index($0, "=") + 1)}' | sed 's/#/0xff/g' | xargs)

    if [[ "$key" == "palette" ]]; then
        # Extract number before "=" (ex: 15)
        index=$(echo "$value" | awk -F '=' '{print $1}')
        # Extract color after "=" (ex: #FF0000)
        color=$(echo "$value" | awk -F '=' '{print $2}')
        # adds color to the palette array
        paletteArr+=("$color")

    else
        keys+=("$key")
        values+=("$value")
        formattedPalette+="export $key=$value\n"
    fi
done < $file

rm -f $file
touch $file
paletteArrOutput="export palette=("
for color in "${paletteArr[@]}"; do
    paletteArrOutput+="\"$color\" "
done
paletteArrOutput+=")\n"
# ${paletteArr[@]})\n"

printf "$paletteArrOutput" >> $file
printf "$formattedPalette" >> $file
