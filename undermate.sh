USERNAME=$1

if [ ! -d $USERNAME ]; then
  chessdump $USERNAME
fi

for f in $USERNAME/*.json; do
  jq -r '
    .games[]
    | select(.pgn | test("=[nbr]#"; "i"))
    | .url
  ' "$f"
done
